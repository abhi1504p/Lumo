import 'package:get/get.dart';
import '../Pages/my_settings/settings_view.dart';
import '../auth/auth_gate.dart';
import '../auth/login_or_register.dart';
import '../home/home_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => const AuthGate(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginOrRegister(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeWidget(),
    ),
    GetPage(
      name: '/settings',
      page: () => SettingsView(),
    ),
  ];
}
