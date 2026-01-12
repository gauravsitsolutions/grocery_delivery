import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/painters/delivery_map_painters.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_bottom_card.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_map_background.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_markers.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_top_bar.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background (Simulated)
          const DeliveryMapBackground(),

          // 2. Custom Route Line (Painter)
          Positioned.fill(
            child: CustomPaint(
              painter: RoutePainter(),
            ),
          ),

          // Markers (Simulated positions)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2, // Destination
            right: MediaQuery.of(context).size.width * 0.25,
            child: const DestinationMarker(),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.45, // User
            left: MediaQuery.of(context).size.width * 0.3,
            child: const UserMarker(),
          ),

          // 3. Top Floating Bar
          const DeliveryTopBar(),

          // 4. Bottom Information Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DeliveryBottomCard(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}
