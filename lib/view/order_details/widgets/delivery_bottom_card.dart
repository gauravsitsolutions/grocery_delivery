import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/delivery_verification_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';

class DeliveryBottomCard extends StatelessWidget {
  final OrderViewModel viewModel;

  const DeliveryBottomCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // If order is null, handle gracefully (though ideally shouldn't happen here if accessed properly)
    if (viewModel.order == null) return const SizedBox.shrink();

    final order = viewModel.order!;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header / Avatar Row
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.grey200,
                child: Icon(Remix.user_line, color: AppColors.grey500),
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
                        color: AppColors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.user?.fullName ?? "Valued Customer",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(Remix.phone_fill, () async {
                final phone = order.user?.mobile ?? '';
                debugPrint('📞 [DeliveryBottomCard] Calling customer mobile no: $phone (Customer: ${order.user?.fullName}, Order #${order.orderNumber})');
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: phone,
                );
                await launchUrl(launchUri);
              }),
              const SizedBox(width: 12),
              _buildActionButton(Remix.chat_4_fill, () {
                // Chat action
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Address Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Remix.map_pin_fill,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "DELIVERY ADDRESS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFullAddressDialog(
                          context, order.deliveryAddress),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See Full',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Remix.arrow_right_s_line,
                              size: 14,
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _buildAddress(order.deliveryAddress),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Main Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
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
                foregroundColor: AppColors.white,
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
          color: AppColors.paleGreen, // Light green
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 22),
      ),
    );
  }

  String _buildAddress(DeliveryAddress? address) {
    if (address == null) return 'Address not available';

    // Build address parts, filtering out empty/null values
    final parts = <String>[];

    if (address.addressLine1.isNotEmpty) {
      parts.add(address.addressLine1);
    }

    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      parts.add(address.addressLine2!);
    }

    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }

    if (address.state.isNotEmpty) {
      parts.add(address.state);
    }

    if (address.postcode.isNotEmpty) {
      parts.add(address.postcode);
    }

    // If no parts were added, return fallback
    if (parts.isEmpty) {
      return 'Address details not available';
    }

    // Join parts with comma and space
    return parts.join(', ');
  }

  void _showFullAddressDialog(BuildContext context, DeliveryAddress? address) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Remix.map_pin_fill,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (address != null) ...[
                      if (address.addressLine1.isNotEmpty) ...[
                        _addressRow('Street', address.addressLine1),
                        const SizedBox(height: 12),
                      ],
                      if (address.addressLine2 != null &&
                          address.addressLine2!.isNotEmpty) ...[
                        _addressRow('Area', address.addressLine2!),
                        const SizedBox(height: 12),
                      ],
                      if (address.city.isNotEmpty) ...[
                        _addressRow('City', address.city),
                        const SizedBox(height: 12),
                      ],
                      if (address.state.isNotEmpty) ...[
                        _addressRow('State', address.state),
                        const SizedBox(height: 12),
                      ],
                      if (address.postcode.isNotEmpty)
                        _addressRow('Postcode', address.postcode),
                    ] else
                      const Text(
                        'Address not available',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
