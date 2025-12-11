import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:style_diary/main.dart';
import 'package:styled_widget/styled_widget.dart';
import 'style_statistics_logic.dart';

class StyleStatisticsPage extends GetView<StyleStatisticsLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics',style: TextStyle(color: Colors.white),),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: GetBuilder<StyleStatisticsLogic>(
        builder: (_) {
          return SafeArea(
            child: SingleChildScrollView(
              child: <Widget>[
                _statCard('Total Entries', '${controller.stats['totalEntries'] ?? 0}', Icons.article),
                _statCard('Total Words', '${controller.stats['totalWords'] ?? 0}', Icons.text_fields),
                _statCard('Collected', '${controller.stats['collectedCount'] ?? 0}', Icons.star),
                _statCard('Categories', '${controller.stats['categoryCount'] ?? 0}', Icons.category),
                _statCard('Moods Tracked', '${controller.stats['moodCount'] ?? 0}', Icons.mood),
              ]
                  .toColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min)
                  .marginAll(15),
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

