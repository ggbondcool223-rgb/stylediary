import 'package:get/get.dart';

import 'style_template_logic.dart';

class StyleTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      StyleTemplateLogic(),
      permanent: true,
    );
  }
}
