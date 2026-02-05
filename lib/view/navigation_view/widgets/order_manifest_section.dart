import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';

class OrderManifestSection extends StatelessWidget {
  final List<OrderItem> items;

  const OrderManifestSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ORDER MANIFEST',
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w800,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(R.w(8)),
              ),
              child: Text(
                '${items.length} ITEMS',
                style: TextStyle(
                  fontSize: R.sp(10),
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(12)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => SizedBox(height: R.h(12)),
          itemBuilder: (context, index) {
            final item = items[index];
            final product = item.product;
            return Container(
              padding: EdgeInsets.all(R.w(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.w(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: R.w(64),
                    height: R.w(64),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(R.w(32)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(R.w(32)),
                      child: CustomNetworkImage(
                        imageUrl: product?.productImageUrls.isNotEmpty == true
                            ? product!.productImageUrls.first
                            : (product?.productImages.isNotEmpty == true
                                ? AppUrls.productImages +
                                    product!.productImages.first
                                : ''),
                        placeholder: const Icon(Icons.shopping_basket,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.name ?? 'Unknown Item',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: R.h(2)),
                        Text(
                          product?.unitValue ?? '',
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          _getItemPrice(item),
                          style: TextStyle(
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(12), vertical: R.h(6)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF7F1),
                      borderRadius: BorderRadius.circular(R.w(12)),
                    ),
                    child: Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w800,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getItemPrice(OrderItem item) {
    // Try to use the price field first
    if (item.price != null &&
        item.price!.isNotEmpty &&
        item.price != '0.00' &&
        item.price != '0') {
      return '₹${item.price}';
    }

    // Fallback to total if price is not available
    if (item.total.isNotEmpty && item.total != '0.00' && item.total != '0') {
      return '₹${item.total}';
    }

    // Fallback to lineTotal if available
    if (item.lineTotal != null &&
        item.lineTotal!.isNotEmpty &&
        item.lineTotal != '0.00' &&
        item.lineTotal != '0') {
      return '₹${item.lineTotal}';
    }

    // Last resort: check product price
    if (item.product?.retailerPrice != null &&
        item.product!.retailerPrice.isNotEmpty &&
        item.product!.retailerPrice != '0.00') {
      return '₹${item.product!.retailerPrice}';
    }

    return '₹0.00';
  }
}
