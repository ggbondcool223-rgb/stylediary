import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:style_diary/main.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import 'style_main_logic.dart';

class StyleMainPage extends GetView<StyleMainLogic> {
  Widget _topItem(int index) {
    final titles = ['Diary', 'Calendar', 'Collection', 'Setting'];
    return Expanded(
        child: <Widget>[
      Obx(() {
        return Text(
          titles[index],
          style: TextStyle(
              color: controller.style.value == index
                  ? Colors.white
                  : Colors.white.withAlpha(150),
              fontSize: 16,
              fontWeight: controller.style.value == index
                  ? FontWeight.w900
                  : FontWeight.normal),
        );
      }),
      const SizedBox(height: 5),
      Obx(() {
        return Visibility(
          visible: controller.style.value == index,
          child: Image.asset('assets/icon0.png'),
        );
      })
    ].toColumn(mainAxisSize: MainAxisSize.min).gestures(onTap: () {
      controller.style.value = index;
      controller.getData();
    }));
  }

  Widget _settingItem(int index) {
    final titles = ['Clean diary', 'Clean collection', 'Statistics', 'Export data', 'Import data', 'App version'];
    return Container(
      width: double.infinity,
      height: 40,
      child: <Widget>[
        Expanded(
            child: Text(
          titles[index],
        )),
        index != 5
            ? const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
                size: 25,
              )
            : Obx(() {
                return Text(
                  controller.appVersion.value,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              })
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
    ).decorated(color: Colors.transparent).gestures(onTap: () {
      if (index == 0) {
        controller.cleanDiaryData();
      } else if (index == 1) {
        controller.cleanCollectionData();
      } else if (index == 2) {
        Get.toNamed('/statistics');
      } else if (index == 3) {
        controller.exportData();
      } else if (index == 4) {
        controller.importData();
      }
    });
  }

  Widget _searchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) {
          controller.performSearch(value);
        },
        decoration: const InputDecoration(
          hintText: 'Search entries...',
          border: InputBorder.none,
          icon: Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    ).marginOnly(bottom: 10);
  }

  Widget _moodFilter() {
    return SizedBox(
      height: 34,
      child: Obx(() {
        return GridView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 34 / 80),
            itemCount: controller.moodList.length,
            itemBuilder: (_, index) {
              final mood = controller.moodList[index];
              final moodEmojis = {
                'All': '',
                'Happy': '😊',
                'Sad': '😢',
                'Neutral': '😐',
                'Excited': '🤩',
                'Tired': '😴',
              };
              return Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: controller.selectedMood.value == mood
                          ? primaryColor
                          : const Color(0xffead8c9)),
                  child: Text(
                    '${moodEmojis[mood] ?? ''} $mood',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: controller.selectedMood.value == mood
                            ? Colors.white
                            : primaryColor),
                  ),
                ).gestures(onTap: () {
                  controller.selectedMood.value = mood;
                  controller.getData();
                });
              });
            });
      }),
    );
  }

  Widget _diaryTypeGridViewPage() {
    return SizedBox(
      height: 34,
      child: Obx(() {
        return GridView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 34 / 110),
            itemCount: controller.typeList.length + 1,
            itemBuilder: (_, index) {
              if (index == controller.typeList.length) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xff707070))),
                  child: const Text(
                    '+ Custom',
                    style: TextStyle(fontSize: 16, color: Color(0xff626262)),
                  ),
                ).gestures(onTap: () {
                  controller.addTypeData();
                });
              }
              final entity = controller.typeList[index];
              return Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: controller.type.value == entity
                          ? primaryColor
                          : const Color(0xffead8c9)),
                  child: Text(
                    entity,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: controller.type.value == entity
                            ? Colors.white
                            : primaryColor),
                  ),
                ).gestures(onTap: () {
                  controller.type.value = controller.typeList[index];
                  controller.getData();
                });
              });
            });
      }),
    );
  }

  Widget _gridViewPage() {
    return Obx(() {
      return controller.list.isEmpty
          ? const Center(
              child: Text('No Data'),
            ).marginOnly(top: 300)
          : GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 163 / 240),
              itemCount: controller.list.length,
              itemBuilder: (_, index) {
                final entity = controller.list[index];
                final moodEmojis = {
                  'Happy': '😊',
                  'Sad': '😢',
                  'Neutral': '😐',
                  'Excited': '🤩',
                  'Tired': '😴',
                };
                return <Widget>[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                  ).decorated(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(40))),
                  <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entity.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (entity.mood.isNotEmpty)
                          Text(
                            moodEmojis[entity.mood] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (entity.tagList.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: entity.tagList.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ).marginOnly(bottom: 5),
                    Expanded(
                      child: Text(
                        entity.content,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entity.createdTimeStr,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (entity.wordCount > 0)
                          Text(
                            '${entity.wordCount}w',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                      ],
                    ),
                  ]
                      .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
                      .marginSymmetric(vertical: 15, horizontal: 15),
                  Positioned(
                      top: 15,
                      left: 0,
                      child: Container(
                        width: 2,
                        height: 20,
                      ).decorated(color: primaryColor))
                ].toStack().gestures(onTap: () {
                  Get.toNamed('/editStyle', arguments: entity)
                      ?.then((_) {
                    controller.getData();
                  });
                });
              });
    });
  }

  Widget _page() {
    return Obx(() {
      Widget page = const SizedBox();
      if (controller.style.value == 0) {
        page = <Widget>[
          _searchBar(),
          _diaryTypeGridViewPage(),
          const SizedBox(height: 10),
          _moodFilter(),
          const SizedBox(height: 10),
          _gridViewPage()
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
      } else if (controller.style.value == 1) {
        page = <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            calendarFormat: controller.calendarFormat,
            onFormatChanged: (format) {
              if (controller.calendarFormat != format) {
                controller.calendarFormat = format;
                controller.update();
              }
            },
            currentDay: controller.currentDate,
            calendarStyle: CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              controller.currentDate = selectedDay;
              controller.update();
              controller.getData();
            },
          ),
          const SizedBox(
            height: 10,
          ),
          _gridViewPage(),
        ].toColumn();
      } else if (controller.style.value == 2) {
        page = <Widget>[
          _searchBar(),
          _gridViewPage(),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
      } else if (controller.style.value == 3) {
        page = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: <Widget>[
            _settingItem(0),
            _settingItem(1),
            _settingItem(2),
            _settingItem(3),
            _settingItem(4),
            _settingItem(5),
          ]
              .toColumn(
                  separator: Divider(
            height: 15,
            color: Colors.grey.shade300,
          )),
        ).decorated(
            color: Colors.white, borderRadius: BorderRadius.circular(16));
      }
      return page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: <Widget>[_topItem(0), _topItem(1), _topItem(2), _topItem(3)]
            .toRow(),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        backgroundColor: const Color(0xffff9300),
        child: const Icon(Icons.add),
        onPressed: () {
          if (controller.typeList.length <= 1) {
            Fluttertoast.showToast(msg: 'Please add diary type first');
            return;
          }
          Get.toNamed('/editStyle',
                  parameters: controller.style.value == 1
                      ? {'date': controller.currentDate.toIso8601String()}
                      : null)
              ?.then((_) {
            controller.getData();
          });
        },
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
            child: GetBuilder<StyleMainLogic>(builder: (_) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: <Widget>[_page()].toColumn(),
          );
        }).marginAll(15)),
      ),
    );
  }
}
