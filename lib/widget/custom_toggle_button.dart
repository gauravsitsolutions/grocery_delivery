import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart'; // R helper

class RemixIconToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RemixIconToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ❗ R.init(context) must be called in parent screen (not here)

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: R.w(52), // ⬅ responsive
        height: R.h(28), // ⬅ responsive
        padding: EdgeInsets.all(R.w(3)), // ⬅ responsive
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.r(30)), // ⬅ responsive
          color: value ? AppColors.primaryGreen : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: R.w(22), // ⬅ responsive
            height: R.w(22), // ⬅ responsive
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? Remix.check_line : Remix.close_line,
              size: R.sp(14), // ⬅ responsive
              color: value ? AppColors.primaryGreen : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
