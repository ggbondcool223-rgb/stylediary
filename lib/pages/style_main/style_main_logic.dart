import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:style_diary/db_style/db_style.dart';
import 'package:style_diary/db_style/style_entity.dart';
import 'package:style_diary/pages/style_edit/style_text_field.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';

class StyleMainLogic extends GetxController {
  DBStyle dbStyle = Get.find();

  var list = <StyleEntity>[].obs;
  var typeList = ['All'].obs;
  var moodList = ['All', 'Happy', 'Sad', 'Neutral', 'Excited', 'Tired'].obs;

  var style = 0.obs;
  var type = 'All'.obs;
  var selectedMood = 'All'.obs;
  var searchQuery = ''.obs;
  CalendarFormat calendarFormat = CalendarFormat.month;
  var currentDate = DateTime.now();

  var appVersion = '1.0.0'.obs;

  getData() async {
    var result = await dbStyle.getStyleAllData();
    final types = await dbStyle.getTypeAllData();
    typeList.value = types..insert(0, 'All');
    
    if (searchQuery.value.isNotEmpty) {
      result = await dbStyle.searchEntries(searchQuery.value);
    }
    
    if (style.value == 0) {
      if (type.value != 'All') {
        result = result.where((element) => element.type == type.value).toList();
      }
      if (selectedMood.value != 'All') {
        result = result.where((element) => element.mood == selectedMood.value).toList();
      }
    } else if (style.value == 1) {
      result = result
          .where((element) =>
              element.createdTime.year == currentDate.year &&
              element.createdTime.month == currentDate.month &&
              element.createdTime.day == currentDate.day)
          .toList();
    } else if (style.value == 2) {
      result = result.where((element) => element.isCollected == 1).toList();
    }
    list.value = result;
  }
  
  void performSearch(String query) {
    searchQuery.value = query;
    getData();
  }

  addTypeData() async {
    String title = '';
    Get.dialog(AlertDialog(
      title: const Text(
        'Add new type',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Container(
        width: 300,
        height: 50,
        child: StyleTextField(
            value: title,
            maxLength: 6,
            textAlign: TextAlign.center,
            onChange: (v) {
              title = v;
            }),
      ).decorated(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffd3d3d3))),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (title.isEmpty) {
              Fluttertoast.showToast(msg: 'Please enter type name');
              return;
            }
            if (typeList.contains(title)) {
              Fluttertoast.showToast(msg: 'Type name already exists');
              return;
            }
            await dbStyle.insertType(title);
            await getData();
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));
  }

  cleanDiaryData() async {
    Get.dialog(AlertDialog(
      title: const Text('Warm reminder'),
      content: const Text('Do you want to clean all diary?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            await dbStyle.cleanStyleData();
            await getData();
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ));
  }

  cleanCollectionData() async {
    Get.dialog(AlertDialog(
      title: const Text('Warm reminder'),
      content: const Text('Do you want to clean all collection?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            await dbStyle.cleanStyleCollection(list);
            await getData();
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ));
  }

  Future<void> exportData() async {
    try {
      var allData = await dbStyle.exportAllData();
      var jsonData = allData.map((e) => e.toJson()).toList();
      var jsonString = jsonEncode(jsonData);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/diary_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      Fluttertoast.showToast(msg: 'Exported to: ${file.path}');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Export failed: $e');
    }
  }

  Future<void> importData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      
      if (files.isEmpty) {
        Fluttertoast.showToast(msg: 'No export files found');
        return;
      }
      
      Get.dialog(AlertDialog(
        title: const Text('Select file to import'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(files[index].path.split('/').last),
                onTap: () async {
                  Get.back();
                  var content = await files[index].readAsString();
                  var jsonData = jsonDecode(content) as List;
                  var entities = jsonData.map((e) => StyleEntity.fromJson(e)).toList();
                  await dbStyle.importData(entities);
                  Fluttertoast.showToast(msg: 'Imported ${entities.length} entries');
                  getData();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Import failed: $e');
    }
  }

  @override
  void onInit() async {
    var info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    getData();
    super.onInit();
  }
}
