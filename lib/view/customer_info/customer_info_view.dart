import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/slide_to_complete_widget.dart';

class CustomerInfoView extends StatefulWidget {
  const CustomerInfoView({super.key});

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  bool instructionsRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.headingText),
        title: const Text(
          'Order #48291',
          style: TextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              RemixIcons.customer_service_fill,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
        child: Column(
          children: [
            _customerCard(),
            const SizedBox(height: 16),
            _mapCard(),
            const SizedBox(height: 16),
            _instructionCard(),
            const SizedBox(height: 24),
            _orderHeader(),
            const SizedBox(height: 12),
            _orderItem(
              'Organic Bananas',
              '1 bunch • \$2.49',
              'https://images.unsplash.com/photo-1574226516831-e1dff420e37b?w=400',
            ),
            _orderItem(
              'Whole Milk',
              '1 gallon • \$4.99',
              'https://images.unsplash.com/photo-1585238342028-4bbc0d77b7aa?w=400',
            ),
            _orderItem(
              'Sourdough Bread',
              'Sliced • \$5.49',
              'https://images.unsplash.com/photo-1608198093002-de2b4f20b7b8?w=400',
            ),
          ],
        ),
      ),

      // ================= BOTTOM =================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Verify all items before completing order',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              SlideToCompleteWidget(
                enabled: instructionsRead,
                onCompleted: () {
                  Navigator.pushNamed(context, AppRoutes.navigation_view);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CUSTOMER =================

  Widget _customerCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/women/44.jpg',
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah Jenkins',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Customer since 2021',
                    style: TextStyle(
                      color: AppColors.bodyText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.phone_line,
                  label: 'Call',
                  bg: AppColors.primaryGreen,
                  textColor: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.message_3_line,
                  label: 'Message',
                  bg: AppColors.borderLight,
                  textColor: AppColors.headingText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MAP =================

  Widget _mapCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=900',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'DISTANCE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2.4 km • 15 mins',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DROP-OFF LOCATION',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '1234 Green Street, Apt 4B',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'San Francisco, CA 94109',
                        style: TextStyle(color: AppColors.bodyText),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.borderLight,
                  child: Icon(
                    Icons.navigation,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= INSTRUCTIONS =================

  Widget _instructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF7E0), // alert bg (can move to AppColors later)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: AppColors.headingText),
              SizedBox(width: 8),
              Text(
                'DELIVERY INSTRUCTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Gate Code: 1234. Please do not ring the doorbell, baby is sleeping.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('I have read the instructions'),
              ),
              RemixIconToggle(
                value: instructionsRead,
                onChanged: (v) => setState(() => instructionsRead = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ORDER =================

  Widget _orderHeader() {
    return Row(
      children: const [
        Text(
          'Order Items (5)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Spacer(),
        Text(
          'Est. Earnings: \$18.50',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _orderItem(
    String title,
    String subtitle,
    String image, {
    String qty = 'x1',
  }) {
    return _card(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.borderLight,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              qty,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
