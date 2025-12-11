import 'dart:async';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_diary/db_style/db_style.dart';
import 'package:style_diary/db_style/style_entity.dart';

class StyleEditLogic extends GetxController {
  DBStyle dbStyle = Get.find();

  StyleEntity? styleEntity = Get.arguments;

  List<String> typeList = [];
  List<String> availableTags = [];
  List<String> selectedTags = [];

  DateTime createdTime = DateTime.now();

  var type = ''.obs;
  var mood = ''.obs;
  var wordCount = 0.obs;
  var characterCount = 0.obs;
  var paragraphCount = 0.obs;
  var isFullscreen = false.obs;
  var fontSize = 16.0.obs;
  var textAlignment = TextAlign.left.obs;
  var showSearchBar = false.obs;
  var searchQuery = ''.obs;
  var replaceQuery = ''.obs;
  
  String title = '';
  String content = '';
  
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();
  
  List<String> undoStack = [];
  List<String> redoStack = [];
  Timer? autoSaveTimer;
  static const int maxUndoHistory = 20;

  final List<Map<String, String>> templates = [
    {'name': 'Daily', 'title': 'Daily Reflection', 'content': 'Today I...\n\nHighlights:\n\nThoughts:\n\nTomorrow I will...'},
    {'name': 'Work', 'title': 'Work Notes', 'content': 'Meeting:\n\nTasks:\n\nNotes:\n\nAction Items:'},
    {'name': 'Gratitude', 'title': 'Gratitude Journal', 'content': 'I am grateful for:\n\n1.\n\n2.\n\n3.\n\nToday I learned:'},
  ];

  final List<Map<String, String>> moods = [
    {'emoji': '😊', 'name': 'Happy'},
    {'emoji': '😢', 'name': 'Sad'},
    {'emoji': '😐', 'name': 'Neutral'},
    {'emoji': '🤩', 'name': 'Excited'},
    {'emoji': '😴', 'name': 'Tired'},
  ];

  int calculateWordCount(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  void updateStatistics() {
    final fullText = title + ' ' + content;
    wordCount.value = calculateWordCount(fullText);
    characterCount.value = fullText.length;
    paragraphCount.value = content.split('\n\n').where((p) => p.trim().isNotEmpty).length;
  }

  void saveToHistory() {
    final currentState = '$title|||$content';
    if (undoStack.isEmpty || undoStack.last != currentState) {
      undoStack.add(currentState);
      if (undoStack.length > maxUndoHistory) {
        undoStack.removeAt(0);
      }
      redoStack.clear();
    }
  }

  void undo() {
    if (undoStack.length > 1) {
      final currentState = undoStack.removeLast();
      redoStack.add(currentState);
      final previousState = undoStack.last;
      final parts = previousState.split('|||');
      if (parts.length == 2) {
        title = parts[0];
        content = parts[1];
        titleController.text = title;
        contentController.text = content;
        updateStatistics();
        update();
      }
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      final nextState = redoStack.removeLast();
      undoStack.add(nextState);
      final parts = nextState.split('|||');
      if (parts.length == 2) {
        title = parts[0];
        content = parts[1];
        titleController.text = title;
        contentController.text = content;
        updateStatistics();
        update();
      }
    }
  }

  void startAutoSave() {
    autoSaveTimer?.cancel();
    autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await saveDraft();
    });
  }

  Future<void> saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = styleEntity != null ? 'draft_${styleEntity!.id}' : 'draft_new';
      await prefs.setString(draftKey, '$title|||$content|||${type.value}|||${mood.value}|||${selectedTags.join(',')}');
    } catch (e) {
    }
  }

  Future<void> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftKey = styleEntity != null ? 'draft_${styleEntity!.id}' : 'draft_new';
      final draft = prefs.getString(draftKey);
      if (draft != null && draft.isNotEmpty) {
        final parts = draft.split('|||');
        if (parts.length >= 5) {
          Get.dialog(AlertDialog(
            title: const Text('Draft Found'),
            content: const Text('Restore unsaved draft?'),
            actions: [
              TextButton(
                onPressed: () async {
                  await prefs.remove(draftKey);
                  Get.back();
                },
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () {
                  title = parts[0];
                  content = parts[1];
                  type.value = parts[2];
                  mood.value = parts[3];
                  selectedTags = parts[4].split(',').where((t) => t.isNotEmpty).toList();
                  titleController.text = title;
                  contentController.text = content;
                  updateStatistics();
                  update();
                  Get.back();
                },
                child: const Text('Restore'),
              ),
            ],
          ));
        }
      }
    } catch (e) {
    }
  }

  void insertTextAtCursor(String text, {bool isTitle = false}) {
    final controller = isTitle ? titleController : contentController;
    final selection = controller.selection;
    final newText = controller.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
    if (isTitle) {
      title = newText;
    } else {
      content = newText;
    }
    saveToHistory();
    updateStatistics();
    update();
  }

  void insertDateTime() async {
    if (!contentFocusNode.hasFocus) {
      contentFocusNode.requestFocus();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final now = DateTime.now();
    final formatted = DateFormat('MM/dd/yyyy HH:mm').format(now);
    insertTextAtCursor(formatted);
  }

  void insertLink() {
    Get.dialog(AlertDialog(
      title: const Text('Insert Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Link Text'),
            onChanged: (value) => replaceQuery.value = value,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: 'URL'),
            onChanged: (value) => searchQuery.value = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (replaceQuery.isNotEmpty && searchQuery.isNotEmpty) {
              insertTextAtCursor('[$replaceQuery]($searchQuery)');
              searchQuery.value = '';
              replaceQuery.value = '';
              Get.back();
            }
          },
          child: const Text('Insert'),
        ),
      ],
    ));
  }

  void setFontSize(double size) {
    fontSize.value = size;
    update();
  }

  void setTextAlignment(TextAlign align) {
    textAlignment.value = align;
    update();
  }

  void formatText(String format) {
    final controller = contentController;
    final selection = controller.selection;
    if (!selection.isValid) return;
    
    final selectedText = controller.text.substring(
      selection.start,
      selection.end,
    );
    String formattedText = '';
    
    switch (format) {
      case 'bold':
        formattedText = selectedText.isEmpty ? '**text**' : '**$selectedText**';
        break;
      case 'italic':
        formattedText = selectedText.isEmpty ? '*text*' : '*$selectedText*';
        break;
      case 'underline':
        formattedText = selectedText.isEmpty ? '__text__' : '__${selectedText}__';
        break;
      case 'list':
        formattedText = selectedText.isEmpty
            ? '- item'
            : selectedText.split('\n').map((line) => '- $line').join('\n');
        break;
    }
    
    if (formattedText.isNotEmpty) {
      final newText = controller.text.replaceRange(
        selection.start,
        selection.end,
        formattedText,
      );
      controller.text = newText;
      final newOffset = selectedText.isEmpty
          ? selection.start + formattedText.length - 4
          : selection.start + formattedText.length;
      controller.selection = TextSelection.collapsed(offset: newOffset);
      content = newText;
      saveToHistory();
      updateStatistics();
      update();
    }
  }

  void searchAndReplace() {
    if (searchQuery.isEmpty) return;
    final text = contentController.text;
    if (text.contains(searchQuery)) {
      final newText = replaceQuery.isEmpty
          ? text
          : text.replaceAll(searchQuery, replaceQuery.value);
      contentController.text = newText;
      content = newText;
      saveToHistory();
      updateStatistics();
      update();
      Fluttertoast.showToast(msg: 'Replaced ${text.split(searchQuery).length - 1} occurrence(s)');
    } else {
      Fluttertoast.showToast(msg: 'Text not found');
    }
  }

  void addData() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (type.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select type');
      return;
    }
    if (title.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter title');
      return;
    }
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter content');
      return;
    }
    
    autoSaveTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    final draftKey = styleEntity != null ? 'draft_${styleEntity!.id}' : 'draft_new';
    await prefs.remove(draftKey);
    
    final tagsString = selectedTags.join(',');
    final currentWordCount = calculateWordCount(title + ' ' + content);
    
    if (styleEntity == null) {
      await dbStyle.insertStyle(StyleEntity(
          id: 0,
          createdTime: createdTime,
          type: type.value,
          title: title,
          content: content,
          isCollected: 0,
          mood: mood.value,
          tags: tagsString,
          wordCount: currentWordCount,
          isLocked: 0));
    } else {
      await dbStyle.updateStyle(StyleEntity(
          id: styleEntity!.id,
          createdTime: styleEntity!.createdTime,
          type: type.value,
          title: title,
          content: content,
          isCollected: styleEntity!.isCollected,
          mood: mood.value,
          tags: tagsString,
          wordCount: currentWordCount,
          isLocked: styleEntity!.isLocked));
    }
    
    for (var tag in selectedTags) {
      await dbStyle.insertTag(tag);
    }
    
    Fluttertoast.showToast(msg: 'Saved');
    Get.back();
  }

  void selectType() {
    BottomPicker(
      pickerTitle: const Text(''),
      items: typeList.map((e) => Text(e)).toList(),
      onSubmit: (index) {
        type.value = typeList[index];
        update();
      },
    ).show(Get.context!);
  }

  void selectMood() {
    BottomPicker(
      pickerTitle: const Text(''),
      items: moods.map((e) => Text('${e['emoji']} ${e['name']}')).toList(),
      onSubmit: (index) {
        mood.value = moods[index]['name'] ?? '';
        update();
      },
    ).show(Get.context!);
  }

  void applyTemplate(int index) {
    if (index < templates.length) {
      saveToHistory();
      title = templates[index]['title'] ?? '';
      content = templates[index]['content'] ?? '';
      titleController.text = title;
      contentController.text = content;
      updateStatistics();
      update();
    }
  }

  void duplicateEntry() {
    if (styleEntity != null) {
      saveToHistory();
      title = styleEntity!.title;
      content = styleEntity!.content;
      mood.value = styleEntity!.mood;
      selectedTags = List.from(styleEntity!.tagList);
      titleController.text = title;
      contentController.text = content;
      updateStatistics();
      update();
    }
  }

  void collect() async {
    styleEntity?.isCollected = styleEntity!.isCollected == 0 ? 1 : 0;
    update();
    await dbStyle.updateStyle(styleEntity!);
  }

  @override
  void onInit() async {
    typeList = await dbStyle.getTypeAllData();
    availableTags = await dbStyle.getAllTags();
    final para = Get.parameters;
    if (para.containsKey('date')) {
      createdTime = DateTime.parse(para['date']!);
    }
    if (styleEntity != null) {
      type.value = styleEntity!.type;
      title = styleEntity!.title;
      content = styleEntity!.content;
      mood.value = styleEntity!.mood;
      selectedTags = List.from(styleEntity!.tagList);
      wordCount.value = styleEntity!.wordCount;
      titleController.text = title;
      contentController.text = content;
      update();
    } else {
      await loadDraft();
    }
    titleController.addListener(() {
      title = titleController.text;
      saveToHistory();
      updateStatistics();
    });
    contentController.addListener(() {
      content = contentController.text;
      saveToHistory();
      updateStatistics();
    });
    updateStatistics();
    saveToHistory();
    startAutoSave();
    super.onInit();
  }

  @override
  void onClose() {
    autoSaveTimer?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
}
