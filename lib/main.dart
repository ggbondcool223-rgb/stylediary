
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:style_diary/db_style/db_style.dart';
import 'package:style_diary/pages/style_edit/style_edit_binding.dart';
import 'package:style_diary/pages/style_edit/style_edit_view.dart';
import 'package:style_diary/pages/style_main/style_main_binding.dart';
import 'package:style_diary/pages/style_main/style_main_view.dart';
import 'package:style_diary/pages/style_statistics/style_statistics_binding.dart';
import 'package:style_diary/pages/style_statistics/style_statistics_sort.dart';
import 'package:style_diary/pages/style_statistics/style_statistics_view.dart';
import 'package:style_diary/pages/style_template/style_template_binding.dart';
import 'package:style_diary/pages/style_template/style_template_view.dart';

Color primaryColor = const Color(0xffb48d6b);
Color bgColor = const Color(0xfff7f1e5);

List<GetPage<dynamic>> Runner = [
  GetPage(name: '/', page: () => StyleTemplateView(), binding: StyleTemplateBinding()),
  GetPage(name: '/mainStyle', page: () => StyleMainPage(), binding: StyleMainBinding()),
  GetPage(name: '/editStyle', page: () => StyleEditPage(), binding: StyleEditBinding()),
  GetPage(name: '/statistics', page: () => StyleStatisticsPage(), binding: StyleStatisticsBinding()),
  GetPage(name: '/statisticsSort', page: () => StyleStatisticsSort()),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Get.putAsync(() => DBStyle().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: Runner,
      initialRoute: '/',
      theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: bgColor,
          colorScheme: ColorScheme.light(
            primary: primaryColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          )
      ),
    );
  }
}
