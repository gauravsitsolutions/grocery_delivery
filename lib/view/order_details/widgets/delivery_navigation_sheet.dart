import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/delivery_verification_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';

class DeliveryNavigationSheet extends StatelessWidget {
  final Order order;
  final VoidCallback onExpand;

  const DeliveryNavigationSheet({
    super.key,
    required this.order,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          onExpand();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Customer Info Row
            Row(
              children: [
                // Status Indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Dropping off to",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  order.user?.fullName ?? "Customer",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Customer Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage(
                          'assets/images/profile_placeholder.png'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: order.user?.profilePhoto == null
                      ? Icon(Remix.user_fill, color: AppColors.grey500)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Distance & ETA
            Row(
              children: [
                Icon(Remix.map_pin_2_fill, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                const Text(
                  "1.2 km", // Mock Data
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Remix.time_fill, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                const Text(
                  "5 mins ETA", // Mock Data
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: order.user?.mobile ?? '',
                      );
                      await launchUrl(launchUri);
                    },
                    icon: const Icon(Remix.phone_fill, color: Colors.white),
                    label: const Text("Call Customer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (order.deliveryAddress != null) {
                        final address = order.deliveryAddress!;
                        final fullAddress =
                            "${address.addressLine1}, ${address.city}, ${address.state} ${address.postcode}";
                        final Uri googleMapsUrl = Uri.parse(
                            "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(fullAddress)}");
                        await launchUrl(googleMapsUrl,
                            mode: LaunchMode.externalApplication);
                      } else {
                        // CustomSnackBar.showError(context, "Delivery address not found");
                      }
                    },
                    icon: const Icon(Remix.navigation_fill,
                        color: AppColors.primaryGreen),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Chat action
                    },
                    icon:
                        const Icon(Remix.chat_4_fill, color: AppColors.black87),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Arrived at Destination Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final viewModel = context.read<OrderViewModel>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: DeliveryVerificationView(
                          orderId: order.id,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
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
            const SizedBox(height: 16),

            // Swipe Up Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Remix.arrow_up_s_line, size: 16, color: AppColors.grey400),
                const SizedBox(width: 4),
                Text(
                  "SWIPE UP FOR ORDER DETAILS",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
