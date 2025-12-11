import 'package:get/get.dart';
import 'package:style_diary/db_style/db_style.dart';

class StyleStatisticsLogic extends GetxController {
  DBStyle dbStyle = Get.find();
  
  Map<String, int> stats = {};

  @override
  void onInit() async {
    super.onInit();
    await loadStatistics();
  }

  Future<void> loadStatistics() async {
    stats = await dbStyle.getStatistics();
    update();
  }
}

