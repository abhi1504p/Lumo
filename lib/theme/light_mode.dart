import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    surface: Colors.grey.shade100,
    onSurface: AppColors.textPrimary,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),





);
