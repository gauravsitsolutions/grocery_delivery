import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';

class CustomerDetailsCard extends StatelessWidget {
  final String name;
  final String membershipType;
  final String address;
  final String? profileImage;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const CustomerDetailsCard({
    super.key,
    required this.name,
    required this.membershipType,
    required this.address,
    this.profileImage,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOMER DETAILS',
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight: FontWeight.w800,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: R.h(12)),
        Container(
          padding: EdgeInsets.all(R.w(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(R.w(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: R.w(56),
                    height: R.w(56),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(R.w(28)),
                      child: CustomNetworkImage(
                        imageUrl: profileImage ?? '',
                        placeholder:
                            const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: R.sp(20),
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          membershipType,
                          style: TextStyle(
                            fontSize: R.sp(14),
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(20)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: R.sp(20)),
                  SizedBox(width: R.w(8)),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.call,
                      label: 'Call',
                      onTap: onCall,
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.message,
                      label: 'Message',
                      onTap: onMessage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(12)),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF7F1),
          borderRadius: BorderRadius.circular(R.w(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: R.sp(20)),
            SizedBox(width: R.w(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
