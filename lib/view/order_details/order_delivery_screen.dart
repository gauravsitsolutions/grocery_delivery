import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/painters/delivery_map_painters.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_map_background.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_markers.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/delivery_navigation_sheet.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/map_control_buttons.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/navigation_instruction_card.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';

class OrderDeliveryScreen extends StatefulWidget {
  const OrderDeliveryScreen({super.key});

  @override
  State<OrderDeliveryScreen> createState() => _OrderDeliveryScreenState();
}

class _OrderDeliveryScreenState extends State<OrderDeliveryScreen> {
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    // Ensure we have an order to show
    if (viewModel.order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

          // Markers
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

          // 3. Navigation Instruction Card (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: NavigationInstructionCard(
              instruction: "Turn Right onto Oak Avenue",
              distance: "In 200 Meters",
              isMuted: _isMuted,
              onMuteToggle: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
              },
            ),
          ),

          // 4. Map Controls (Right Side)
          Positioned(
            right: 20,
            bottom: 300, // Above bottom sheet
            child: const MapControlButtons(),
          ),

          // 5. Navigation Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DeliveryNavigationSheet(
              order: viewModel.order!,
              onExpand: () {
                // Handle expansion (e.g. show full details)
                // For now, maybe just show a snackbar or navigate to details
              },
            ),
          ),
        ],
      ),
    );
  }
}
