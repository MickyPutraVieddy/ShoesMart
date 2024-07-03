import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_mart/view/screens/welcome_screen.dart';
import 'package:shop_mart/view/widgets/splashscreen.dart';

import 'firebase_options.dart';
import 'language/localization.dart';
import 'logic/controllers/theme_controller.dart';
import 'routes/routes.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(GetStorage().read<String>('lang').toString()),
      fallbackLocale: Locale('en'),
      translations: LocalizationApp(),
      title: 'Zain"s Shop',
      theme: ThemesApp.light,
      darkTheme: ThemesApp.dark,
      themeMode: ThemeController().getThemeDataGet,
      home: FutureBuilder(
        future: _initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return splashscreen();
          } else {
            return WelcomeScreen();
          }
        },
      ),
      routes: {
        AppRoutes.welcome: (context) => WelcomeScreen(),
      },
    );
  }

  Future<void> _initializeData() async {
    // Delay selama 5 detik
    await Future.delayed(const Duration(seconds: 5));
  }
}
