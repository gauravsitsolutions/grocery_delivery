import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PaymentCollectionCard extends StatelessWidget {
  final String totalAmount;
  final String paymentMethod;

  const PaymentCollectionCard({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isCOD = paymentMethod.toUpperCase().contains('COD') ||
        paymentMethod.toUpperCase().contains('CASH');

    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F1),
        borderRadius: BorderRadius.circular(R.w(32)),
        border:
            Border.all(color: Colors.green.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total to Collect',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(R.w(8)),
                ),
                child: Text(
                  isCOD ? 'COD' : paymentMethod.toUpperCase(),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(4)),
          Text(
            '₹$totalAmount',
            style: TextStyle(
              fontSize: R.sp(32),
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              Icon(Icons.payments, color: Colors.green[700], size: R.sp(16)),
              SizedBox(width: R.w(8)),
              Text(
                isCOD ? 'CASH ON DELIVERY REQUIRED' : 'PAYMENT ALREADY MADE',
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w800,
                  color: Colors.green[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
