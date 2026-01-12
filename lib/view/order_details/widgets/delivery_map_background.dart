import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/painters/delivery_map_painters.dart';

class DeliveryMapBackground extends StatelessWidget {
  const DeliveryMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mapBackground, // Light grey map color
      child: CustomPaint(
        painter: MapGridPainter(), // faint dot pattern
        child: Container(),
      ),
    );
  }
}
