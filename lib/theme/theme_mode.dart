import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeController extends GetxController {
  // Reactive theme data
  final _themeData = lightMode.obs;

  // Getter for current theme
  ThemeData get themeData => _themeData.value;

  // Getter to check if dark mode is enabled
  bool get isDarkMode => _themeData.value == darkMode;

  // Method to toggle between light and dark themes
  void toggleTheme() {
    _themeData.value = _themeData.value == lightMode ? darkMode : lightMode;
  }

  // Optional: Direct setter if needed
  void setTheme(ThemeData theme) {
    _themeData.value = theme;
  }
}
