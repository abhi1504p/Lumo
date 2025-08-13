import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:lumo/Pages/chat_page/chat_page_view.dart';
import 'package:lumo/auth/auth_gate.dart';
import 'package:lumo/auth/login_or_register.dart';
import 'package:lumo/home/home_view.dart';
import 'package:lumo/theme/light_mode.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      theme: lightMode,
      getPages: [
        GetPage(name: '/home', page: () => HomeWidget()),
        GetPage(name: '/login', page: () => LoginOrRegister()),

      ],
    );
  }
}
