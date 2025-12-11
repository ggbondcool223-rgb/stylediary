import 'package:get/get.dart';

import 'style_edit_logic.dart';

class StyleEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StyleEditLogic());
  }
}