import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/core/widgets/app_button.dart';
import 'package:lumo/core/widgets/app_input_field.dart';
import 'package:lumo/core/widgets/app_text.dart';
import 'login_page_logic.dart';

class LoginPageView extends StatelessWidget {
  final void Function()? onTap;

  LoginPageView({super.key, required this.onTap});

  // Inject the controller
  final LoginPageLogic loginController = Get.put(LoginPageLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              AppText.body("Sign in to continue chatting with people."),
              const SizedBox(height: 20),

              // Email input
              AppInputField(
                controller: loginController.emailController,
                labeltext: "Email",
                keyboardType: TextInputType.emailAddress,
                obscureTexts: false,
              ),
              const SizedBox(height: 10),

              // Password input
              AppInputField(
                controller: loginController.passwordController,
                labeltext: "Password",
                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              const SizedBox(height: 30),

              // Login button with loading state
              Obx(() => AppButton(
                type: ButtonType.filled,
                text: loginController.isLoading.value ? "Logging in..." : "Login",
                width: double.infinity,
                onPressed: loginController.isLoading.value
                    ? null
                    : loginController.login,
              )),
              const SizedBox(height: 25),

              // Register navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.body(
                    "Not a member?  ",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: AppText.body(
                      "Register now",
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
