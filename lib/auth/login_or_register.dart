import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/login_page.dart';
import '../pages/register_page.dart';
import 'login_or_register_controller.dart';

class LoginOrRegister extends StatelessWidget {
  LoginOrRegister({super.key});

  LoginOrRegisterController loginOrRegisterController = Get.put(
    LoginOrRegisterController(),
  );

  @override
  Widget build(BuildContext context) {
   return Obx((){
     if (loginOrRegisterController.showLoginPage.value) {
       return LoginPage(ontap: loginOrRegisterController.togglePages);
     } else {
       return RegisterPage(ontap: loginOrRegisterController.togglePages);
     }
   });
  }
}
