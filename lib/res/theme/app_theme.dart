import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class AppTheme {
  AppTheme._(); // prevents instantiation

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: false, // keep UI unchanged
    scaffoldBackgroundColor: AppColors.scaffoldBg,

    // Colors
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.black,
      surface: AppColors.scaffoldBg,
      onSurface: AppColors.black,
    ),

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: R.sp(18),
        fontWeight: FontWeight.w600,
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBg,
      hintStyle: const TextStyle(color: AppColors.hintText),
      prefixIconColor: AppColors.inputIcon,
      suffixIconColor: AppColors.inputIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: _outlineBorder(AppColors.inputBorder),
      enabledBorder: _outlineBorder(AppColors.inputBorder),
      focusedBorder: _outlineBorder(AppColors.primaryGreen),
      errorBorder: _outlineBorder(AppColors.error),
      focusedErrorBorder: _outlineBorder(AppColors.error),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.black,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: R.sp(16),
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Icons
    iconTheme: const IconThemeData(
      color: AppColors.black,
      size: 22,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.inputBorder,
      thickness: 1,
      space: 24,
    ),
  );

  // Reusable border
  static OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}
