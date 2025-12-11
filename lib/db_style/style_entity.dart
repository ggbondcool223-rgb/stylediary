import 'package:intl/intl.dart';

class StyleEntity {
  int id;
  DateTime createdTime;
  String type = '';
  String title;
  String content;
  int isCollected;
  String mood;
  String tags;
  int wordCount;
  int isLocked;

  StyleEntity({
    required this.id,
    required this.createdTime,
    required this.type,
    required this.title,
    required this.content,
    required this.isCollected,
    this.mood = '',
    this.tags = '',
    this.wordCount = 0,
    this.isLocked = 0,
  });

  factory StyleEntity.fromJson(Map<String, dynamic> json) {
    return StyleEntity(
      id: json['id'],
      createdTime: DateTime.parse(json['createdTime']),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isCollected: json['isCollected'] ?? 0,
      mood: json['mood'] ?? '',
      tags: json['tags'] ?? '',
      wordCount: json['wordCount'] ?? 0,
      isLocked: json['isLocked'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTime': createdTime.toIso8601String(),
      'type': type,
      'title': title,
      'content': content,
      'isCollected': isCollected,
      'mood': mood,
      'tags': tags,
      'wordCount': wordCount,
      'isLocked': isLocked,
    };
  }

  String get createdTimeStr => DateFormat('MM/dd/yyyy').format(createdTime);
  
  int get readingTimeMinutes => (wordCount / 200).ceil();
  
  List<String> get tagList => tags.isEmpty ? [] : tags.split(',').where((t) => t.trim().isNotEmpty).toList();
}

class TypeEntity {
  int id;
  String name;

  TypeEntity({
    required this.id,
    required this.name,
  });

  factory TypeEntity.fromJson(Map<String, dynamic> json) {
    return TypeEntity(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}