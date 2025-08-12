import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/service/auth_service.dart';

class RegisterPageLogic extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> register() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authService = AuthService();
    isLoading.value = true;

    try {
      await authService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Navigate to another page after successful registration
      // Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
