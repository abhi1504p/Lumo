import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumo/service/auth_service.dart';

class LoginPageLogic extends GetxController {
  // Controllers for text fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs; // To show loading spinner if needed

  // Login function
  Future<void> login() async {
    final authService = AuthService();
    isLoading.value = true;

    try {
      await authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // If login successful, you can navigate:
      // Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        "Login Failed",
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
    super.onClose();
  }
}
