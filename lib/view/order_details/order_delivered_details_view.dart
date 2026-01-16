import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDeliveredDetailsView extends StatelessWidget {
  final Order order;

  const OrderDeliveredDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: Offset(0, -R.h(40)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                child: Column(
                  children: [
                    _buildCustomerCard(),
                    SizedBox(height: R.h(16)),
                    _buildRouteCard(),
                    SizedBox(height: R.h(16)),
                    _buildProofCard(),
                    SizedBox(height: R.h(16)),
                    _buildManifestCard(),
                    SizedBox(height: R.h(16)),
                    _buildFinancialStatusCard(),
                    SizedBox(height: R.h(30)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + R.h(10),
        bottom: R.h(60),
        left: R.w(16),
        right: R.w(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Remix.arrow_left_line,
                        color: AppColors.white, size: R.sp(24)),
                  ),
                  SizedBox(width: R.w(8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER DETAILS',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: R.sp(10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (order.deliveredAt != null)
                Text(
                  DateFormat('MMM dd, h:mm a')
                      .format(order.deliveredAt!.toLocal()),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: R.h(20)),
          Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withOpacity(0.2),
            ),
            child: Icon(
              order.status.toLowerCase() == 'cancelled'
                  ? Remix.close_circle_fill
                  : Remix.check_double_fill,
              color: AppColors.white,
              size: R.sp(24),
            ),
          ),
          SizedBox(height: R.h(12)),
          Text(
            order.status.toUpperCase(),
            style: TextStyle(
              color: AppColors.white,
              fontSize: R.sp(24),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: R.h(6)),
          Text(
            order.status.toLowerCase() == 'cancelled'
                ? 'Order was cancelled'
                : 'Successfully dropped off at ${order.deliveredAt != null ? DateFormat('h:mm a').format(order.deliveredAt!.toLocal()) : ''}',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: R.sp(13),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: R.h(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryChip(
                Remix.calendar_line,
                'Today',
              ),
              SizedBox(width: R.w(12)),
              _buildSummaryChip(
                Remix.time_line,
                '14 mins', // Placeholder duration as discussed
              ),
              SizedBox(width: R.w(12)),
              _buildSummaryChip(
                Remix.map_pin_line,
                '2.4 km', // Placeholder distance as discussed
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.bodyText, size: R.sp(14)),
          SizedBox(width: R.w(6)),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: R.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Row(
        children: [
          Container(
            width: R.w(50),
            height: R.w(50),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(R.r(16)),
            ),
            child: order.user?.profilePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(16)),
                    child: CachedNetworkImage(
                      imageUrl: order.user!.profilePhoto!.startsWith('http')
                          ? order.user!.profilePhoto!
                          : '${AppUrls.baseUrl}/${order.user!.profilePhoto}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                          Remix.user_fill,
                          color: AppColors.grey400,
                          size: R.sp(24)),
                    ),
                  )
                : Icon(Remix.user_fill,
                    color: AppColors.grey400, size: R.sp(24)),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTOMER',
                  style: TextStyle(
                    color: AppColors.hintText,
                    fontSize: R.sp(10),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  order.user?.fullName ?? 'Customer',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              if (order.user?.mobile != null) {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: order.user!.mobile,
                );
                await launchUrl(launchUri);
              }
            },
            child: Container(
              padding: EdgeInsets.all(R.w(10)),
              decoration: const BoxDecoration(
                color: AppColors.paleGreen, // Light green
                shape: BoxShape.circle,
              ),
              child: Icon(
                Remix.phone_fill,
                color: AppColors.primaryGreen,
                size: R.sp(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY ROUTE',
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: R.sp(11),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: R.h(20)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(Remix.checkbox_circle_fill,
                      color: AppColors.primaryGreen, size: R.sp(16)),
                  Container(
                    width: 1,
                    height: R.h(40),
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ],
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP LOCATION',
                      style: TextStyle(
                        color: AppColors.hintText,
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      order.vendor?.storeName ?? 'Warehouse Hub',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.vendor?.address ??
                          'Avenue 5, Logistics Park, Sector 12',
                      style: TextStyle(
                          color: AppColors.bodyText, fontSize: R.sp(13)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Remix.map_pin_fill,
                  color: AppColors.primaryGreen, size: R.sp(16)),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROP LOCATION',
                      style: TextStyle(
                        color: AppColors.hintText,
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      order.user?.fullName ?? 'Valued Customer',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.deliveryAddress != null
                          ? '${order.deliveryAddress!.addressLine1}, ${order.deliveryAddress!.city}'
                          : 'Customer Address',
                      style: TextStyle(
                          color: AppColors.bodyText, fontSize: R.sp(13)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProofCard() {
    if (order.pickupProof == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Remix.image_fill, color: AppColors.hintText, size: R.sp(16)),
              SizedBox(width: R.w(8)),
              Text(
                'PICKUP PROOF',
                style: TextStyle(
                  color: AppColors.hintText,
                  fontSize: R.sp(11),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.r(12)),
            child: CachedNetworkImage(
              imageUrl: order.pickupProof!.startsWith('http')
                  ? order.pickupProof!
                  : (order.pickupProof!.startsWith('/')
                      ? '${AppUrls.baseUrl}/storage${order.pickupProof}'
                      : '${AppUrls.baseUrl}/storage/${order.pickupProof}'),
              height: R.h(150),
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.grey200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey200,
                child: const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManifestCard() {
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MANIFEST',
            style: TextStyle(
              color: AppColors.hintText,
              fontSize: R.sp(11),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: R.h(16)),
          ...order.orderItems.map((item) {
            String? productImage;
            if (item.product != null &&
                item.product!.productImages.isNotEmpty) {
              productImage = item.product!.productImages.first;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: R.h(12)),
              child: Row(
                children: [
                  Container(
                    width: R.w(48),
                    height: R.w(48),
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(R.r(8)),
                      image: productImage != null
                          ? DecorationImage(
                              image: NetworkImage(productImage
                                      .startsWith('http')
                                  ? productImage
                                  : '${AppUrls.productImages}$productImage'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: productImage == null
                        ? Icon(Remix.image_line,
                            size: R.sp(20), color: AppColors.grey)
                        : null,
                  ),
                  SizedBox(width: R.w(12)),
                  Container(
                    padding: EdgeInsets.all(R.w(8)),
                    decoration: BoxDecoration(
                      color: AppColors.softGreyBg,
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: R.sp(12)),
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: Text(
                      item.product?.name ?? 'Item',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialStatusCard() {
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        children: [
          _buildRow('Status', 'Paid',
              isBold: true, color: AppColors.primaryGreen),
          SizedBox(height: R.h(12)),
          _buildRow('Subtotal', '₹${order.subtotal}'),
          SizedBox(height: R.h(8)),
          _buildRow('Delivery', '₹${order.deliveryCharge}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: R.h(12)),
            child: Divider(color: AppColors.grey200, height: 1),
          ),
          _buildRow('Total Amount', '₹${order.totalAmount}',
              isBold: true, size: 16),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? color, double? size}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: R.sp(14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: R.sp(size ?? 14),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
