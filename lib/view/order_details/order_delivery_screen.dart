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

    return Column(
      children: [
        _buildCustomerCard(context, viewModel),
        const SizedBox(height: 16),
        _buildMapSection(context, viewModel),
        const SizedBox(height: 16),
        _buildInstructionsSection(context, viewModel),
        const SizedBox(height: 80), // Space for footer
      ],
    );
  }

  Widget _buildCustomerCard(BuildContext context, OrderViewModel viewModel) {
    final order = viewModel.order!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: Text(
                  order.user?.fullName[0] ?? "C",
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.user?.fullName ?? "Customer",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Customer Since 2023",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: order.user?.mobile ?? '',
                  );
                  await launchUrl(launchUri);
                },
                icon:
                    const Icon(Remix.phone_fill, color: AppColors.primaryGreen),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, OrderViewModel viewModel) {
    final order = viewModel.order!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Remix.map_pin_2_fill,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Delivery Location",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Remix.navigation_line, size: 14),
                label: const Text("Navigate"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${order.deliveryAddress?.addressLine1 ?? ''} ${order.deliveryAddress?.addressLine2 ?? ''}, ${order.deliveryAddress?.city ?? ''}, ${order.deliveryAddress?.state ?? ''}, ${order.deliveryAddress?.postcode ?? ''}",
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage(
                    "https://maps.googleapis.com/maps/api/staticmap?center=12.9716,77.5946&zoom=14&size=600x300&key=YOUR_KEY"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(
      BuildContext context, OrderViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Remix.information_line, color: Color(0xFF0052CC), size: 18),
              SizedBox(width: 8),
              Text(
                "Delivery Instructions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0052CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Please leave the package at the front door and ring the bell. Customer requested no-contact delivery.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              viewModel.hasReadInstructions = !viewModel.hasReadInstructions;
            },
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: viewModel.hasReadInstructions,
                    onChanged: (v) => viewModel.hasReadInstructions = v!,
                    activeColor: const Color(0xFF0052CC),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "I have read and understood instructions",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0052CC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
