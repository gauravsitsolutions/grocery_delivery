import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background (Simulated)
          _buildMapBackground(),

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
            child: const _DestinationMarker(),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.45, // User
            left: MediaQuery.of(context).size.width * 0.3,
            child: const _UserMarker(),
          ),

          // 3. Top Floating Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Remix.arrow_left_line,
                  onTap: () => Navigator.pop(context),
                ),
                _buildEstTimeCard(),
                _buildCircleButton(
                  icon: Remix.more_2_fill,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 4. Bottom Information Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCard(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      color: const Color(0xFFE8ECEF), // Light grey map color
      child: CustomPaint(
        painter: MapGridPainter(), // faint dot pattern
        child: Container(),
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _buildEstTimeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "ESTIMATED ARRIVAL",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "12 mins",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: " · 3.2 km",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard(BuildContext context, OrderViewModel viewModel) {
    final order = viewModel.order!;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Avatar Row
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[200],
                child: Icon(Remix.user_line, color: Colors.grey[500]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.orderNumber}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.user?.fullName ?? "Valued Customer",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(Remix.phone_fill, () async {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: order.user?.mobile ?? '',
                );
                await launchUrl(launchUri);
              }),
              const SizedBox(width: 12),
              _buildActionButton(Remix.chat_4_fill, () {
                // Chat action
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Remix.map_pin_fill,
                  color: AppColors.primaryGreen, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DELIVERY ADDRESS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.deliveryAddress?.addressLine1 ?? ''}, ${order.deliveryAddress?.city ?? ''}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Implement "Arrived" logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
              ),
              child: const Text(
                "Arrived at Destination",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Light green
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 22),
      ),
    );
  }
}

// --- Custom Painters for Visuals ---

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.5;

    const step = 40.0;

    // Draw dots
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF69F0AE).withValues(alpha: 0.8) // Brand Green light
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create a curved path similar to the image
    // Starting near bottom left (User)
    final startX = size.width * 0.3;
    final startY = size.height * 0.55; // aligned with bottom marker

    // Ending near top right (Destination)
    final endX = size.width * 0.75;
    final endY = size.height * 0.2; // aligned with top marker

    path.moveTo(startX, startY);

    // Curve control points
    final cp1X = size.width * 0.3;
    final cp1Y = size.height * 0.35;

    final cp2X = size.width * 0.5;
    final cp2Y = size.height * 0.15;

    path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Center(
            child: Icon(Remix.map_pin_fill,
                color: AppColors.primaryGreen, size: 28),
          ),
        ),
      ],
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF448AFF), // Blue
          shape: BoxShape.circle,
        ),
        child: const Icon(Remix.navigation_fill, color: Colors.white, size: 20),
      ),
    );
  }
}
