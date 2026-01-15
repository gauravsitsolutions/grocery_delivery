import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';

class OrderCancelledDetailsView extends StatelessWidget {
  final Order order;

  const OrderCancelledDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
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
                    _buildReasonCard(),
                    SizedBox(height: R.h(16)),
                    _buildRouteCard(),
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
      color: const Color(0xFFEF4444), // Red color
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + R.h(10),
        bottom: R.h(60),
        left: R.w(16),
        right: R.w(16),
      ),
      child: Column(
        children: [
          // Top Row: Back + Order ID + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(RemixIcons.arrow_left_line,
                        color: Colors.white, size: R.sp(24)),
                  ),
                  SizedBox(width: R.w(8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER DETAILS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: R.sp(10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd, h:mm a').format(order.createdAt.toLocal()),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(30)),

          // Icon
          Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Icon(
              RemixIcons.close_fill,
              color: Colors.white,
              size: R.sp(24),
            ),
          ),
          SizedBox(height: R.h(12)),

          // Status Text
          Text(
            'CANCELLED',
            style: TextStyle(
              color: Colors.white,
              fontSize: R.sp(24),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: R.h(6)),
          Text(
            'Refund will be processed within 24-48 hours',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: R.sp(13),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
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
              Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEF2F2), // Light red
                ),
                child: Icon(
                  RemixIcons.error_warning_fill,
                  color: const Color(0xFFEF4444),
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REASON FOR CANCELLATION',
                      style: TextStyle(
                        color: const Color(0xFFEF4444),
                        fontSize: R.sp(11),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      order.cancelReason ?? 'Cancelled by vendor',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Divider(color: Colors.grey[200], height: 1),
          SizedBox(height: R.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(RemixIcons.user_fill,
                  color: const Color(0xFF6B7280), size: R.sp(14)),
              SizedBox(width: R.w(6)),
              RichText(
                text: TextSpan(
                  text: 'Initiated by ',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: R.sp(13),
                    fontFamily: 'Inter', // Assuming Inter or default
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Delivery Agent', // Since this is the agent app context usually
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                        fontSize: R.sp(13),
                      ),
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

  Widget _buildRouteCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY ROUTE',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: R.sp(11),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: R.h(20)),

          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(RemixIcons.checkbox_blank_circle_fill,
                      color: const Color(0xFF111827), size: R.sp(16)),
                  Container(
                    width: 1,
                    height: R.h(40),
                    color: const Color(0xFFE5E7EB),
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
                        color: const Color(0xFF9CA3AF),
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Central Warehouse Hub',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sector 56, Industrial Area, Gate 4',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: R.sp(13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(RemixIcons.checkbox_blank_circle_fill,
                  color: const Color(0xFFEF4444), size: R.sp(16)),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTENDED DROP-OFF',
                      style: TextStyle(
                        color: const Color(0xFFEF4444),
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Home • ${order.deliveryAddress?.addressLine1 ?? ''}',
                      style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.deliveryAddress != null)
                      Text(
                        '${order.deliveryAddress?.addressLine2 ?? ''}, ${order.deliveryAddress?.city ?? ''}, ${order.deliveryAddress?.state ?? ''} - ${order.deliveryAddress?.postcode ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: R.sp(13),
                        ),
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

  Widget _buildManifestCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER MANIFEST (${order.orderItems.length})',
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: R.sp(11),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(R.r(6)),
                ),
                child: Text(
                  '\$${order.totalAmount}',
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(20)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.orderItems.length,
            separatorBuilder: (context, index) => SizedBox(height: R.h(16)),
            itemBuilder: (context, index) {
              final item = order.orderItems[index];

              // Handle image extraction safely
              String? imageUrl;
              if (item.product?.productImages.isNotEmpty == true) {
                imageUrl =
                    AppUrls.productImages + item.product!.productImages.first;
              }

              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    child: Container(
                      width: R.w(60),
                      height: R.w(60),
                      color: Colors.grey[100],
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product?.name ?? 'Product',
                          style: TextStyle(
                            color: const Color(0xFF1F2937),
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          '${item.quantity} unit • \$${item.price}',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: R.sp(13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      color: const Color(0xFF1F2937),
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light green
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FINANCIAL STATUS',
                style: TextStyle(
                  color: const Color(0xFF15803D), // Green
                  fontSize: R.sp(9),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: R.h(4)),
              Text(
                'Refund Processed Successfully',
                style: TextStyle(
                  color: const Color(0xFF166534),
                  fontSize: R.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(R.w(4)),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF22C55E),
            ),
            child: Icon(RemixIcons.check_line,
                color: Colors.white, size: R.sp(12)),
          ),
        ],
      ),
    );
  }
}
