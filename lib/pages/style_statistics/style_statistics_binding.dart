import 'package:get/get.dart';
import 'package:style_diary/pages/style_statistics/style_statistics_logic.dart';

class StyleStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StyleStatisticsLogic());
  }
}

