import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cropreserve/repository/local_base.dart';

import 'screens/home_screen.dart';
import 'bases/hive_base.dart';
import 'screens/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(HiveUserAdapter());
  await Hive.openBox<HiveUser>(localDB);
  Box<bool> _onBoardBox = await Hive.openBox("onBoardBox");
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('tr', 'TR')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(
        onBoardBox: _onBoardBox,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Box onBoardBox;

  const MyApp({Key key, @required this.onBoardBox}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: "CropSaver",
      home: widget.onBoardBox.values.isEmpty
          ? OnBoardingPage(
              onBoardBox: widget.onBoardBox,
            )
          : HomeScreen(),
    );
  }
}
