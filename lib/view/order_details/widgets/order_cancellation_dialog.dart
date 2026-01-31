import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/model/cancellation_reason_model.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class OrderCancellationDialog extends StatefulWidget {
  final List<CancellationReason> reasons;

  const OrderCancellationDialog({super.key, required this.reasons});

  @override
  State<OrderCancellationDialog> createState() =>
      _OrderCancellationDialogState();
}

class _OrderCancellationDialogState extends State<OrderCancellationDialog> {
  int? _selectedReasonId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.grey400, size: 24),
                ),
                Expanded(
                  child: Center(
                    child: const Text(
                      'Cancel Order?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Please select a reason for cancelling this task.\nThis helps us improve your experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Reasons List
            widget.reasons.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No reasons available"),
                  )
                : Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: widget.reasons.map((reason) {
                          final isSelected = _selectedReasonId == reason.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedReasonId = reason.id;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey200,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reason.reason,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.black87,
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.error
                                            : AppColors.grey300,
                                        width: isSelected ? 6 : 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReasonId == null
                    ? null
                    : () {
                        Navigator.pop(context, _selectedReasonId);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                      AppColors.error.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Go Back Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.grey100,
                  foregroundColor: AppColors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
