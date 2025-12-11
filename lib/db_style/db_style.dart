import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:style_diary/db_style/style_entity.dart';

class DBStyle extends GetxService {
  late Database dbBase;
  static const int dbVersion = 2;

  Future<DBStyle> init() async {
    await createStyleDB();
    return this;
  }

  createStyleDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'style.db');

    dbBase = await openDatabase(path, version: dbVersion,
        onCreate: (Database db, int version) async {
      await createTypeTable(db);
      await createStyleTable(db);
      await createTagTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE style ADD COLUMN mood TEXT DEFAULT ""');
        await db.execute('ALTER TABLE style ADD COLUMN tags TEXT DEFAULT ""');
        await db.execute('ALTER TABLE style ADD COLUMN wordCount INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE style ADD COLUMN isLocked INTEGER DEFAULT 0');
        await createTagTable(db);
      }
    });
  }

  createTypeTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS type (id INTEGER PRIMARY KEY, type TEXT)');
  }

  createStyleTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS style (id INTEGER PRIMARY KEY, createdTime TEXT, type TEXT, title TEXT, content TEXT, isCollected INTEGER, mood TEXT DEFAULT "", tags TEXT DEFAULT "", wordCount INTEGER DEFAULT 0, isLocked INTEGER DEFAULT 0)');
  }

  createTagTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS tag (id INTEGER PRIMARY KEY, name TEXT UNIQUE)');
  }

  insertType(String type) async {
    final id = await dbBase.insert('type', {'type': type});
    return id;
  }

  insertStyle(StyleEntity entity) async {
    final id = await dbBase.insert('style', {
      'createdTime': entity.createdTime.toIso8601String(),
      'type': entity.type,
      'title': entity.title,
      'content': entity.content,
      'isCollected': entity.isCollected,
      'mood': entity.mood,
      'tags': entity.tags,
      'wordCount': entity.wordCount,
      'isLocked': entity.isLocked,
    });
    return id;
  }

  updateStyle(StyleEntity entity) async {
    await dbBase.update('style', {
      'type': entity.type,
      'title': entity.title,
      'content': entity.content,
      'isCollected': entity.isCollected,
      'mood': entity.mood,
      'tags': entity.tags,
      'wordCount': entity.wordCount,
      'isLocked': entity.isLocked,
    }, where: 'id = ?', whereArgs: [entity.id]);
  }

  cleanStyleCollection(List<StyleEntity> list) async {
    for (var item in list) {
      await dbBase.update('style', {
        'isCollected': 0,
      }, where: 'id = ?', whereArgs: [item.id]);
    }
  }

  cleanStyleData() async {
    await dbBase.delete('style');
    await dbBase.delete('type');
  }

  Future<List<String>> getTypeAllData() async {
    var result = await dbBase.query('type', orderBy: 'id');
    return result.map((e) => e['type'] as String).toList();
  }

  Future<List<StyleEntity>> getStyleAllData() async {
    var result = await dbBase.query('style', orderBy: 'createdTime DESC');
    return result.map((e) => StyleEntity.fromJson(e)).toList();
  }

  Future<List<StyleEntity>> searchEntries(String query) async {
    var result = await dbBase.query('style',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdTime DESC');
    return result.map((e) => StyleEntity.fromJson(e)).toList();
  }

  Future<List<String>> getAllTags() async {
    var result = await dbBase.query('tag', orderBy: 'name');
    return result.map((e) => e['name'] as String).toList();
  }

  Future<void> insertTag(String tag) async {
    try {
      await dbBase.insert('tag', {'name': tag}, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
    }
  }

  Future<Map<String, int>> getStatistics() async {
    var allEntries = await getStyleAllData();
    var totalEntries = allEntries.length;
    var totalWords = allEntries.fold<int>(0, (sum, e) => sum + e.wordCount);
    var collectedCount = allEntries.where((e) => e.isCollected == 1).length;
    var categoryCount = <String, int>{};
    var moodCount = <String, int>{};
    
    for (var entry in allEntries) {
      categoryCount[entry.type] = (categoryCount[entry.type] ?? 0) + 1;
      if (entry.mood.isNotEmpty) {
        moodCount[entry.mood] = (moodCount[entry.mood] ?? 0) + 1;
      }
    }
    
    return {
      'totalEntries': totalEntries,
      'totalWords': totalWords,
      'collectedCount': collectedCount,
      'categoryCount': categoryCount.length,
      'moodCount': moodCount.length,
    };
  }

  Future<List<StyleEntity>> exportAllData() async {
    return await getStyleAllData();
  }

  Future<void> importData(List<StyleEntity> entries) async {
    var batch = dbBase.batch();
    for (var entry in entries) {
      batch.insert('style', {
        'createdTime': entry.createdTime.toIso8601String(),
        'type': entry.type,
        'title': entry.title,
        'content': entry.content,
        'isCollected': entry.isCollected,
        'mood': entry.mood,
        'tags': entry.tags,
        'wordCount': entry.wordCount,
        'isLocked': entry.isLocked,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
