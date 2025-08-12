import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/auth/register_page/register_page_logic.dart';
import 'package:lumo/core/widgets/app_button.dart';
import 'package:lumo/core/widgets/app_input_field.dart';
import 'package:lumo/core/widgets/app_text.dart';

class RegisterPageView extends StatelessWidget {
  final void Function()? onTap;

  RegisterPageView({super.key, required this.onTap});

  final RegisterPageLogic registerController = Get.put(RegisterPageLogic());

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
              AppText.body("Let's create an account for you."),
              const SizedBox(height: 20),

              // Email field
              AppInputField(
                controller: registerController.emailController,
                labeltext: "Email",
                keyboardType: TextInputType.emailAddress,
                obscureTexts: false,
              ),
              const SizedBox(height: 10),

              // Password field
              AppInputField(
                controller: registerController.passwordController,
                labeltext: "Password",
                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              const SizedBox(height: 10),

              // Confirm password field
              AppInputField(
                controller: registerController.confirmPasswordController,
                labeltext: "Confirm Password",
                keyboardType: TextInputType.text,
                obscureTexts: true,
              ),
              const SizedBox(height: 30),

              // Register button with loading state
              Obx(() => AppButton(
                type: ButtonType.filled,
                text: registerController.isLoading.value
                    ? "Registering..."
                    : "Register",
                width: double.infinity,
                onPressed: registerController.isLoading.value
                    ? null
                    : registerController.register,
              )),
              const SizedBox(height: 25),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.body(
                    "Already have an account?  ",
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: AppText.body(
                      "Login now",
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
