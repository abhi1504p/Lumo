import 'package:get/get.dart';
import 'package:lumo/auth/login_or_register.dart';

import '../../auth/login_page/login_page_logic.dart';
import '../../auth/register_page/register_page_logic.dart';
import '../../service/auth_service.dart';

class My_drawerLogic extends GetxController {
  final authService = AuthService();

  void logout() {
    authService.Signout();

    // Remove old login controller so fields reset
    if (Get.isRegistered<LoginPageLogic>()) {
      Get.delete<LoginPageLogic>();
    }
    if (Get.isRegistered<RegisterPageLogic>()) {
      Get.delete<RegisterPageLogic>();
    }

    // Navigate back to login/register page
    Get.offAll(() => LoginOrRegister());
  }
}
