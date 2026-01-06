import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Main headings (screens, titles)
  static TextStyle get heading => TextStyle(
        fontSize: R.sp(26),
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      );

  /// Sub headings / helper text
  static TextStyle get subHeading => TextStyle(
        fontSize: R.sp(15),
        fontWeight: FontWeight.w400,
        color: AppColors.bodyText,
      );

  /// Labels (form labels, section titles)
  static TextStyle get label => TextStyle(
        fontSize: R.sp(14),
        fontWeight: FontWeight.w600,
        color: AppColors.headingText,
      );

  /// Primary buttons text
  static TextStyle get button => TextStyle(
        fontSize: R.sp(16),
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );
}
