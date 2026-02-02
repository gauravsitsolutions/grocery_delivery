import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class DeliveryMapBackground extends StatelessWidget {
  const DeliveryMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mapBackground,
        image: DecorationImage(
          image: AssetImage('assets/images/map_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
