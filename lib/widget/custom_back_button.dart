import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      icon: Icon(
        Theme.of(context).platform == TargetPlatform.iOS
            ? RemixIcons.arrow_left_s_line
            : RemixIcons.arrow_left_line,
        color: color ?? AppColors.headingText,
        size: R.sp(28),
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
