import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/auth/login_page/login_page_view.dart';
import 'package:lumo/auth/register_page/register_page_view.dart';

import 'login_or_register_controller.dart';

class LoginOrRegister extends StatelessWidget {
  LoginOrRegister({super.key});

  LoginOrRegisterController loginOrRegisterController = Get.put(
    LoginOrRegisterController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loginOrRegisterController.showLoginPage.value) {
        return LoginPageView( onTap:  loginOrRegisterController.togglePages,);
      } else {
        return RegisterPageView(onTap: loginOrRegisterController.togglePages);
      }
    });
  }
}
