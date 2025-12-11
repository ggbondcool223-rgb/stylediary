import 'package:get/get.dart';

import 'style_main_logic.dart';

class StyleMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StyleMainLogic());
  }
}