import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
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
              centerTitle: true,
              leading: const CustomBackButton(color: AppColors.headingText),
              title: Column(
                children: [
                  Text(
                    'Delivery Details',
                    style: TextStyle(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(18),
                    ),
                  ),
                  Text(
                    '#${order.orderNumber}',
                    style: TextStyle(
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: R.sp(13),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    RemixIcons.more_2_fill,
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
                    SizedBox(
                      width: double.infinity,
                      height: R.h(56),
                      child: ElevatedButton(
                        onPressed: instructionsRead
                            ? () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.navigationView,
                                  arguments: order,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(28)),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'START DELIVERY',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: R.w(8)),
                            Icon(RemixIcons.arrow_right_line, size: R.sp(20)),
                          ],
                        ),
                      ),
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
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: R.r(35),
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: Text(
                      order.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: R.sp(24),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(R.w(4)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        RemixIcons.checkbox_circle_fill,
                        color: Colors.white,
                        size: R.sp(16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.user?.fullName ?? 'Customer',
                      style: TextStyle(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(10), vertical: R.h(4)),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(R.r(8)),
                      ),
                      child: Text(
                        'Primary Customer',
                        style: TextStyle(
                          fontSize: R.sp(11),
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  final phone = order.user?.mobile;
                  if (phone != null) {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
                child: CircleAvatar(
                  radius: R.r(24),
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(
                    RemixIcons.phone_fill,
                    color: Colors.white,
                    size: R.sp(22),
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(R.r(32)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=900',
                  height: R.h(220),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: CircleAvatar(
                    radius: R.r(24),
                    backgroundColor: Colors.white,
                    child: Icon(
                      RemixIcons.map_pin_2_fill,
                      color: AppColors.primaryGreen,
                      size: R.sp(24),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: R.h(16),
                left: R.w(16),
                right: R.w(16),
                child: ElevatedButton(
                  onPressed: () async {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, R.h(50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(25)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RemixIcons.direction_fill, size: R.sp(18)),
                      SizedBox(width: R.w(8)),
                      Text(
                        'Navigate to Drop-off',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(R.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DROP-OFF POINT',
                  style: TextStyle(
                    color: AppColors.bodyText.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: R.sp(11),
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  address?.addressLine1 ?? 'Address not available',
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w800,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  '${address?.city ?? ''}, ${address?.postcode ?? ''}',
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
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
