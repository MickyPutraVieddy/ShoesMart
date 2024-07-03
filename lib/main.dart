import 'package:shop_mart/view/screens/welcome_screen.dart';
import 'package:shop_mart/view/widgets/splashscreen.dart';

import 'utils/my_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'language/localization.dart';
import 'logic/controllers/theme_controller.dart';
import 'routes/routes.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCY_Xv3lT6dM0bH_wqJQH-6-M-DEUiHWv8",
          appId: "1:495969882636:android:1f7f58c3b5edfd44e85429",
          messagingSenderId: "495969882636",
          projectId: "retailshoesstorage"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(GetStorage().read<String>('lang').toString()),
      fallbackLocale: Locale(ene),
      translations: LocalizationApp(),
      title: 'Zain"s Shop',
      theme: ThemesApp.light,
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
      darkTheme: ThemesApp.dark,
      themeMode: ThemeController().getThemeDataGet,
      // initialRoute: FirebaseAuth.instance.currentUser != null ||
      //         GetStorage().read<bool>('auth') == true
      //     ? AppRoutes.splash
      //     : AppRoutes.welcome,
      getPages: AppRoutes.routes,
    );
  }
}

Future<void> _initializeData() async {
  // Delay selama 5 detik
  await Future.delayed(const Duration(seconds: 5));
}
