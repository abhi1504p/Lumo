import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:lumo/core/routes.dart';
import 'package:lumo/auth/auth_gate.dart';
import 'package:lumo/theme/theme_mode.dart';
import 'package:lumo/service/ai_settings_service.dart';
import 'package:lumo/service/chat_services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "a.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController themeController = Get.put(ThemeController());
  final AISettingsService aiSettingsService = Get.put(AISettingsService());
  final ChatServices chatServices = Get.put(ChatServices());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        theme: themeController.themeData,
        initialRoute: '/',
        getPages: AppRoutes.routes,
      );
    });
  }
}
