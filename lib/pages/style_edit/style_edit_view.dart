import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:style_diary/main.dart';
import 'package:style_diary/pages/style_edit/style_text_field.dart';
import 'package:styled_widget/styled_widget.dart';

import 'style_edit_logic.dart';

class StyleEditPage extends GetView<StyleEditLogic> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: Colors.white,
          appBar: controller.isFullscreen.value
              ? null
              : AppBar(
                  title: const Text('Edit diary'),
                  backgroundColor: Colors.transparent,
                  actions: [
                    const Text(
                      'Commit',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ).marginOnly(right: 20).gestures(onTap: () {
                      controller.addData();
                    })
                  ],
                ),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: GetBuilder<StyleEditLogic>(builder: (_) {
                return SafeArea(
                    child: <Widget>[
                  if (!controller.isFullscreen.value) ...[
                    _buildCategorySelector(),
                    const SizedBox(height: 15),
                    _buildMoodSelector(),
                    const SizedBox(height: 15),
                    if (controller.styleEntity == null) _buildTemplates(),
                    _buildTags(),
                    const SizedBox(height: 10),
                  ],
                  _buildFormattingToolbar(),
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  _buildTitleField(),
                  Divider(
                    height: 30,
                    color: Colors.grey.shade300,
                  ),
                  _buildContentField(),
                  _buildStatisticsPanel(),
                  if (controller.styleEntity != null) _buildActionButtons(),
                ].toColumn().marginAll(15));
              }),
            ),
          ),
        ));
  }

  Widget _buildCategorySelector() {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: IgnorePointer(
        child: <Widget>[
          Expanded(
              child: StyleTextField(
                  value: controller.type.value,
                  textAlign: TextAlign.center,
                  hintText: 'Select type',
                  onChange: (_) {})),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
          )
        ].toRow(),
      ),
    )
        .decorated(
            color: const Color(0xfffcfcfc),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xfff0f0f0)))
        .gestures(onTap: () {
      controller.selectType();
    });
  }

  Widget _buildMoodSelector() {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: IgnorePointer(
        child: <Widget>[
          Expanded(
              child: Obx(() => StyleTextField(
                  value: controller.mood.value.isEmpty
                      ? 'Select mood'
                      : controller.mood.value,
                  textAlign: TextAlign.center,
                  hintText: 'Select mood',
                  onChange: (_) {}))),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
          )
        ].toRow(),
      ),
    )
        .decorated(
            color: const Color(0xfffcfcfc),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xfff0f0f0)))
        .gestures(onTap: () {
      controller.selectMood();
    });
  }

  Widget _buildTemplates() {
    return <Widget>[
      const Text('Templates:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: List.generate(controller.templates.length, (index) {
          return Chip(
            label: Text(controller.templates[index]['name'] ?? ''),
            onDeleted: () {
              controller.applyTemplate(index);
            },
            deleteIcon: const Icon(Icons.add, size: 18),
          );
        }),
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .marginOnly(bottom: 10);
  }

  Widget _buildTags() {
    return <Widget>[
      const Text('Tags:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      GetBuilder<StyleEditLogic>(
        builder: (_) => Wrap(
          spacing: 8,
          children: [
            ...controller.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  controller.selectedTags.remove(tag);
                  controller.update();
                },
              );
            }),
            Chip(
              label: const Text('+ Add Tag'),
              onDeleted: () {
                _showAddTagDialog();
              },
              deleteIcon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .marginOnly(bottom: 10);
  }

  Widget _buildFormattingToolbar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(
          children: [
            _toolbarButton(Icons.undo, () => controller.undo(),
                controller.undoStack.length > 1),
            _toolbarButton(Icons.redo, () => controller.redo(),
                controller.redoStack.isNotEmpty),
            const VerticalDivider(width: 10),
            _toolbarButton(
                Icons.format_bold, () => controller.formatText('bold'), true),
            _toolbarButton(Icons.format_italic,
                () => controller.formatText('italic'), true),
            _toolbarButton(Icons.format_underlined,
                () => controller.formatText('underline'), true),
            _toolbarButton(Icons.format_list_bulleted,
                () => controller.formatText('list'), true),
            const VerticalDivider(width: 10),
            _toolbarButton(Icons.link, () => controller.insertLink(), true),
            _toolbarButton(
                Icons.access_time, () => controller.insertDateTime(), true),
            _toolbarButton(
                Icons.emoji_emotions, () => _showEmojiPicker(), true),
            const VerticalDivider(width: 10),
            PopupMenuButton<TextAlign>(
              icon: const Icon(Icons.format_align_left, size: 20),
              onSelected: (align) => controller.setTextAlignment(align),
              itemBuilder: (context) => [
                const PopupMenuItem(value: TextAlign.left, child: Text('Left')),
                const PopupMenuItem(
                    value: TextAlign.center, child: Text('Center')),
                const PopupMenuItem(
                    value: TextAlign.right, child: Text('Right')),
              ],
            ),
            PopupMenuButton<double>(
              icon: const Icon(Icons.text_fields, size: 20),
              onSelected: (size) => controller.setFontSize(size),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 14.0, child: Text('Small')),
                const PopupMenuItem(value: 16.0, child: Text('Medium')),
                const PopupMenuItem(value: 18.0, child: Text('Large')),
              ],
            ),
            _toolbarButton(Icons.search, () {
              controller.showSearchBar.value = !controller.showSearchBar.value;
            }, true),
          ],
        ),
      ),
    ).decorated(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _toolbarButton(IconData icon, VoidCallback onTap, bool enabled) {
    return IconButton(
      icon: Icon(icon, size: 20, color: enabled ? Colors.black : Colors.grey),
      onPressed: enabled ? onTap : null,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() => controller.showSearchBar.value
        ? Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Replace with',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) => controller.replaceQuery.value = value,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => controller.showSearchBar.value = false,
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () => controller.searchAndReplace(),
                      child: const Text('Replace'),
                    ),
                  ],
                ),
              ],
            ),
          ).marginOnly(bottom: 10)
        : const SizedBox.shrink());
  }

  Widget _buildTitleField() {
    return TextField(
      focusNode: controller.titleFocusNode,
      controller: controller.titleController,
      maxLength: 30,
      style: TextStyle(fontSize: controller.fontSize.value),
      decoration: const InputDecoration(
        hintText: 'Enter title',
        border: InputBorder.none,
        counterText: '',
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      focusNode: controller.contentFocusNode,
      controller: controller.contentController,
      maxLength: 5000,
      maxLines: 8,
      textAlign: controller.textAlignment.value,
      style: TextStyle(fontSize: controller.fontSize.value),
      decoration: const InputDecoration(
        hintText: 'Enter content',
        border: InputBorder.none,
        counterText: '',
      ),
    );
  }

  Widget _buildStatisticsPanel() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Words', '${controller.wordCount.value}'),
              _statItem('Chars', '${controller.characterCount.value}'),
              _statItem('Paragraphs', '${controller.paragraphCount.value}'),
              _statItem('Reading',
                  '${controller.wordCount.value > 0 ? (controller.wordCount.value / 200).ceil() : 0}m'),
            ],
          ),
        ).marginOnly(top: 8));
  }

  Widget _statItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(
                'assets/icon${controller.styleEntity?.isCollected == 1 ? 2 : 1}.png')
            .gestures(onTap: () {
          controller.collect();
        }),
        const SizedBox(width: 10),
        const Icon(Icons.copy, color: Colors.grey).gestures(onTap: () {
          controller.duplicateEntry();
        }),
      ],
    ).marginOnly(top: 10);
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Add Tag', textAlign: TextAlign.center),
      content: Container(
        width: 300,
        height: 50,
        child: TextField(
          controller: tagController,
          maxLength: 20,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            border: InputBorder.none,
            counterText: '',
          ),
        ).decorated(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffd3d3d3))),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
        ),
        TextButton(
          onPressed: () {
            final tagName = tagController.text.trim();
            if (tagName.isNotEmpty &&
                !controller.selectedTags.contains(tagName)) {
              controller.selectedTags.add(tagName);
              controller.update();
            }
            Get.back();
          },
          child: const Text('OK',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void _showEmojiPicker() {
    Get.bottomSheet(
      Container(
        height: 300,
        child: EmojiPicker(onEmojiSelected: (category, emoji) {
          controller.insertTextAtCursor(emoji.emoji);
          Get.back();
        }),
      ),
      backgroundColor: Colors.white,
    );
  }
}
