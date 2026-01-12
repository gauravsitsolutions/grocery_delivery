import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class MapControlButtons extends StatelessWidget {
  const MapControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Remix.stack_fill, () {}), // Layers
        const SizedBox(height: 12),
        _buildButton(Remix.focus_3_fill, () {}), // Re-center
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildIconButton(Remix.add_line, () {}),
              Container(
                height: 1,
                width: 32,
                color: AppColors.grey200,
              ),
              _buildIconButton(Remix.subtract_line, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.black87),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.black87),
      padding: const EdgeInsets.all(12),
    );
  }
}
