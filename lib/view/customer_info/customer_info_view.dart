import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/slide_to_complete_widget.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

class CustomerInfoView extends StatefulWidget {
  final int? orderId;
  final Order? order;
  const CustomerInfoView({super.key, this.orderId, this.order});

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  bool _localInstructionsRead = false;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(
          orderId: widget.orderId ?? widget.order?.id ?? 0,
          initialOrder: widget.order)
        ..fetchOrderDetails(),
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          final order = viewModel.order;

          if (viewModel.isLoading && order == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (order == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Order not found')),
            );
          }

          final instructionsRead =
              viewModel.hasReadInstructions || _localInstructionsRead;

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
              leading: const CustomBackButton(color: AppColors.headingText),
              title: Text(
                'Order #${order.orderNumber}',
                style: TextStyle(
                  color: AppColors.headingText,
                  fontWeight: FontWeight.w700,
                  fontSize: R.sp(20),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    RemixIcons.customer_service_fill,
                    color: AppColors.headingText,
                    size: R.sp(24),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: viewModel.fetchOrderDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.fromLTRB(R.w(16), R.h(16), R.w(16), R.h(150)),
                child: Column(
                  children: [
                    _customerCard(order),
                    SizedBox(height: R.h(16)),
                    _mapCard(order),
                    SizedBox(height: R.h(16)),
                    _instructionCard(viewModel),
                    SizedBox(height: R.h(24)),
                    _orderHeader(order),
                    SizedBox(height: R.h(12)),
                    if (order.orderItems.isEmpty)
                      const Center(child: Text('No items found'))
                    else
                      ...order.orderItems.map((item) => _orderItem(
                            item.product?.name ?? 'Unknown Item',
                            '${item.quantity}${item.product?.unitValue ?? ''} • ₹${item.total}',
                            (item.product?.productImageUrls.isNotEmpty == true)
                                ? item.product!.productImageUrls.first
                                : '',
                            qty: 'x${item.quantity}',
                          )),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(R.w(16), R.h(8), R.w(16), R.h(16)),
                color: AppColors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm reading instructions before delivery',
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: R.sp(13),
                      ),
                    ),
                    SizedBox(height: R.h(12)),
                    SlideToCompleteWidget(
                      enabled: instructionsRead,
                      onCompleted: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.navigationView,
                          arguments: order,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _customerCard(Order order) {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: R.r(28),
                backgroundColor: AppColors.primaryGreen.withAlpha(30),
                child: Text(
                  order.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: R.sp(20),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.user?.fullName ?? 'Customer',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Order ID: ${order.orderNumber}',
                    style: TextStyle(
                      color: AppColors.bodyText,
                      fontSize: R.sp(13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.phone_line,
                  label: 'Call',
                  bg: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  onTap: () async {
                    final phone = order.user?.mobile;
                    if (phone != null) {
                      final url = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.message_3_line,
                  label: 'Message',
                  bg: AppColors.borderLight,
                  textColor: AppColors.headingText,
                  onTap: () async {
                    final phone = order.user?.mobile;
                    if (phone != null) {
                      final url = Uri.parse('sms:$phone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapCard(Order order) {
    final address = order.deliveryAddress;
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(R.r(20))),
                child: Image.network(
                  'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=900',
                  height: R.h(170),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: R.w(16),
                bottom: R.h(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED DELIVERY',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(blurRadius: 4, color: AppColors.black)
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Today, ASAP',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(blurRadius: 4, color: AppColors.black)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DROP-OFF LOCATION',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(12),
                        ),
                      ),
                      SizedBox(height: R.h(6)),
                      Text(
                        address?.addressLine1 ?? 'Address not available',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        '${address?.city ?? ''} ${address?.postcode ?? ''}',
                        style: TextStyle(color: AppColors.bodyText),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (address != null) {
                      final query = Uri.encodeComponent(
                          "${address.addressLine1}, ${address.city}, ${address.postcode}");
                      final googleMapsUrl =
                          Uri.parse("google.navigation:q=$query");
                      final appleMapsUrl =
                          Uri.parse("https://maps.apple.com/?q=$query");

                      if (await canLaunchUrl(googleMapsUrl)) {
                        await launchUrl(googleMapsUrl);
                      } else if (await canLaunchUrl(appleMapsUrl)) {
                        await launchUrl(appleMapsUrl);
                      }
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.borderLight,
                    child: Icon(
                      Icons.navigation,
                      color: AppColors.black,
                      size: R.sp(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionCard(OrderViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.headingText, size: R.sp(20)),
              SizedBox(width: R.w(8)),
              Text(
                'DELIVERY INSTRUCTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                  fontSize: R.sp(14),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Text(
            viewModel.order?.deliveryInstructions?.isNotEmpty == true
                ? viewModel.order!.deliveryInstructions!
                : 'No specific instructions provided.',
            style: TextStyle(fontSize: R.sp(14)),
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'I have read the instructions',
                  style: TextStyle(fontSize: R.sp(14)),
                ),
              ),
              RemixIconToggle(
                value: viewModel.hasReadInstructions || _localInstructionsRead,
                onChanged: (v) {
                  setState(() => _localInstructionsRead = v);
                  viewModel.hasReadInstructions = v;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderHeader(Order order) {
    return Row(
      children: [
        Text(
          'Order Items (${order.orderItems.length})',
          style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          'Total: ₹${order.totalAmount}',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(14),
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
      margin: EdgeInsets.only(top: R.h(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R.r(12)),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: R.w(56),
                    height: R.h(56),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _noImagePlaceholder(),
                  )
                : _noImagePlaceholder(),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: R.w(12)),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(6)),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(R.r(10)),
            ),
            child: Text(
              qty,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.sp(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noImagePlaceholder() {
    return Container(
      width: R.w(56),
      height: R.h(56),
      color: AppColors.borderLight,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, size: R.sp(24)),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.r(14)),
      child: Container(
        height: R.h(48),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(R.r(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: R.sp(18), color: textColor),
            SizedBox(width: R.w(8)),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: R.sp(14),
              ),
            ),
          ],
        ),
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
      padding: padding ?? EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
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
