import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';

class OrderPickupScreen extends StatelessWidget {
  const OrderPickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Column(
      children: [
        _buildStoreSection(context, viewModel),
        const SizedBox(height: 16),
        _buildItemsList(context, viewModel),
      ],
    );
  }

  Widget _buildStoreSection(BuildContext context, OrderViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Remix.store_2_line,
                    color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Samrudhi Supermarket",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingText,
                      ),
                    ),
                    Text(
                      "Sector 5, HSR Layout, Bangalore",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStoreInfoPill("AISLE", "04"),
              const SizedBox(width: 12),
              _buildStoreInfoPill("BAY", "12"),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "STAGING AREA",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "FREEZER-B2",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
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
                child: _buildSecondaryButton(
                  icon: Remix.user_voice_line,
                  label: "Manager",
                  onTap: () async {
                    final Uri launchUri =
                        Uri(scheme: 'tel', path: '1234567890');
                    await launchUrl(launchUri);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200!),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.bodyText),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OrderViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "INVENTORY CHECKLIST",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "${viewModel.checkedItems.length}/${viewModel.orderItems.length} items verified",
                    style: TextStyle(fontSize: 12, color: AppColors.bodyText),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.summaryOrangeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.orangeBorder),
                ),
                child: const Text(
                  "READY FOR PICKUP",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors
                        .warning, // Using warning which is FF8A00, close to D48806
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: viewModel.orderItems.length,
          itemBuilder: (context, index) {
            final item = viewModel.orderItems[index];
            final isChecked = viewModel.checkedItems.contains(item.id);
            return _buildItemCard(context, viewModel, item, isChecked);
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, OrderViewModel viewModel,
      dynamic item, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : AppColors.grey200!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.product?.productImages != null &&
                    item.product!.productImages.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImage(
                      imageUrl: item.product!.productImages[0],
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.shopping_basket_outlined,
                    color: AppColors.grey),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product?.name ?? "Unknown Item",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.softGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "QTY: ${item.quantity}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Shelf: A4-12",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyText,
                      ),
                    ),
                    const Spacer(),
                    // Report Issue Icon (Subtle)
                    InkWell(
                      onTap: () =>
                          _showReportIssueDialog(context, viewModel, item),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Remix.error_warning_line,
                            size: 18, color: AppColors.grey400),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Checkbox / Loading
          SizedBox(
            width: 24,
            height: 24,
            child: viewModel.isItemVerifying(item.id)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : Checkbox(
                    value: isChecked,
                    activeColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: AppColors.grey300!, width: 2),
                    onChanged: (value) => viewModel.toggleItem(item.id),
                  ),
          )
        ],
      ),
    );
  }

  void _showReportIssueDialog(
      BuildContext context, OrderViewModel viewModel, dynamic item) {
    String selectedIssue = 'out_of_stock';
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Report Issue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: const Icon(Remix.close_line, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Issue Type Section
                    const Text(
                      "What's the issue?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        _buildIssueChip(
                            'Item Out of Stock',
                            'out_of_stock',
                            selectedIssue,
                            (val) => setState(() => selectedIssue = val)),
                        _buildIssueChip(
                            'Damaged Item',
                            'damaged',
                            selectedIssue,
                            (val) => setState(() => selectedIssue = val)),
                        _buildIssueChip(
                            'Incorrect Quantity',
                            'incorrect_quantity',
                            selectedIssue,
                            (val) => setState(() => selectedIssue = val)),
                        _buildIssueChip(
                            'Wrong Item on Shelf',
                            'wrong_item',
                            selectedIssue,
                            (val) => setState(() => selectedIssue = val)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description Input
                    Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.4)),
                        color: AppColors.white,
                      ),
                      child: TextField(
                        controller: descriptionController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryGreen),
                        decoration: const InputDecoration(
                          hintText: 'Describe the issue',
                          hintStyle: TextStyle(color: AppColors.primaryGreen),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await viewModel.reportItemIssue(
                            item.id,
                            selectedIssue,
                            descriptionController.text,
                          );
                          Navigator.pop(dialogContext);
                          if (context.mounted && success) {
                            CustomSnackBar.showSuccess(
                              context,
                              'Issue reported successfully',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit Report',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.paleGreen,
                          foregroundColor: AppColors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildIssueChip(String label, String value, String groupValue,
      Function(String) onSelected) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.paleGreen,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.primaryGreen) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
