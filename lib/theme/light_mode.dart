import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    surface: Colors.grey.shade100,
    onSurface: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    tertiary: Colors.white,
    inversePrimary: AppColors.textColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),





);
