import 'package:get/get.dart';

import '../auth/login_page/login_page_logic.dart';
import '../auth/login_page/login_page_view.dart';
import '../auth/register_page/register_page_logic.dart';
import '../service/auth_service.dart';

class HomeLogic extends GetxController {
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

    // Navigate back to login page
    Get.offAll(
      () => LoginPageView(
        onTap: () {
          // handle register navigation if needed
        },
      ),
    );
  }
}
