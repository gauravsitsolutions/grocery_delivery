import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/delivery_success_view.dart';
import 'package:animations/animations.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryVerificationView extends StatefulWidget {
  final int orderId;
  const DeliveryVerificationView({super.key, required this.orderId});

  @override
  State<DeliveryVerificationView> createState() =>
      _DeliveryVerificationViewState();
}

class _DeliveryVerificationViewState extends State<DeliveryVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  Future<void> _launchMap(String? lat, String? lng, {String? address}) async {
    String googleMapsUrl;

    // EXCLUSIVELY USE ADDRESS per user request
    if (address != null && address.isNotEmpty) {
      googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}";
    } else {
      if (mounted) {
        CustomSnackBar.showError(context, "Address unavailable");
      }
      return;
    }

    final uri = Uri.parse(googleMapsUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw 'Could not launch map';
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, "Could not launch map");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Send OTP automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().sendDeliveryOtp();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered, dismiss keyboard and check for auto-submit
        _focusNodes[index].unfocus();

        // Wait a brief moment to ensure text is updated in controller then verify
        if (_otpCode.length == 4) {
          _verifyOtp();
        }
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {}); // Rebuild to update border colors
  }

  Future<void> _verifyOtp() async {
    final viewModel = context.read<OrderViewModel>();
    if (viewModel.isLoading) return;

    final otp = _otpCode;
    if (otp.length != 4) return;

    final success = await viewModel.verifyDeliveryOtp(otp);

    if (!mounted) return;

    if (success) {
      CustomSnackBar.showSuccess(context, "Delivery Verified Successfully!");

      // Navigate to Delivered Details View
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DeliverySuccessView(
            order: viewModel.order!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      CustomSnackBar.showError(
          context, viewModel.error ?? "Invalid OTP, please try again");
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final user = viewModel.order?.user;
    final mobile = user?.mobile ?? "";
    final maskedMobile = mobile.length >= 10
        ? mobile.replaceRange(
            0, mobile.length > 4 ? mobile.length - 4 : 0, '******')
        : mobile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Verify Delivery",
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(24), vertical: R.h(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: R.h(10)),
              // Header Icon
              AvatarGlow(
                glowColor: AppColors.primaryGreen,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                startDelay: const Duration(milliseconds: 100),
                child: Container(
                  width: R.w(100),
                  height: R.w(100),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Remix.shield_check_line,
                      size: R.sp(50),
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(24)),

              // Drop Off Point & Navigation
              if (viewModel.order?.deliveryAddress != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(R.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.softGreyBg,
                    borderRadius: BorderRadius.circular(R.r(16)),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Drop Off Point",
                            style: TextStyle(
                              fontSize: R.sp(14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyText.withValues(alpha: 0.7),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final address = viewModel.order?.deliveryAddress;

                              // Construct full address string for fallback/context
                              final fullAddress = [
                                address?.addressLine1,
                                address?.addressLine2,
                                address?.city,
                                address?.state,
                                address?.postcode
                              ]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', ');

                              _launchMap(address?.latitude, address?.longitude,
                                  address: fullAddress);
                            },
                            child: Container(
                              padding: EdgeInsets.all(R.w(8)),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(R.r(8)),
                                border: Border.all(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Remix.direction_line,
                                color: AppColors.primaryGreen,
                                size: R.sp(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R.h(8)),
                      Row(
                        children: [
                          Icon(
                            Remix.map_pin_line,
                            size: R.sp(16),
                            color: AppColors.headingText,
                          ),
                          SizedBox(width: R.w(8)),
                          Expanded(
                            child: Text(
                              "${viewModel.order?.deliveryAddress?.addressLine1 ?? ''}, ${viewModel.order?.deliveryAddress?.addressLine2 ?? ''}, ${viewModel.order?.deliveryAddress?.city ?? ''}",
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: R.h(24)),

              // Title and Description
              const Text(
                "Verification Required",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(12)),
              Text(
                "Enter the 4-digit code sent to\n${user?.fullName ?? 'the customer'}'s mobile number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(15),
                  color: AppColors.bodyText.withValues(alpha: 0.7),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (maskedMobile.isNotEmpty) ...[
                SizedBox(height: R.h(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(12), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.softGreyBg,
                    borderRadius: BorderRadius.circular(R.r(20)),
                  ),
                  child: Text(
                    maskedMobile,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                ),
              ],
              SizedBox(height: R.h(24)),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFocused = _focusNodes[index].hasFocus;
                  final hasValue = _controllers[index].text.isNotEmpty;

                  return Container(
                    width: R.w(64),
                    height: R.h(72),
                    margin: EdgeInsets.symmetric(horizontal: R.w(8)),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: R.sp(28),
                        fontWeight: FontWeight.w900,
                        color: AppColors.headingText,
                      ),
                      cursorColor: AppColors.primaryGreen,
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: isFocused || hasValue
                            ? AppColors.primaryGreen.withValues(alpha: 0.05)
                            : AppColors.softGreyBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(R.r(16)),
                          borderSide: BorderSide(
                            color: hasValue
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(R.r(16)),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 2.5,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              SizedBox(height: R.h(24)),

              // Resend Button
              TextButton.icon(
                onPressed: () async {
                  final success =
                      await context.read<OrderViewModel>().resendDeliveryOtp();

                  if (!context.mounted) return;

                  if (success) {
                    CustomSnackBar.showSuccess(
                        context, "OTP Sent Successfully");
                  }
                },
                icon: Icon(Remix.refresh_line, size: R.sp(18)),
                label: Text(
                  "Resend Code",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: R.sp(16),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
              ),

              SizedBox(height: R.h(30)),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: R.h(48),
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          // Address Validation Check
                          final address = viewModel.order?.deliveryAddress;
                          final hasAddress = address != null &&
                              (address.addressLine1.isNotEmpty ||
                                  (address.addressLine2 != null &&
                                      address.addressLine2!.isNotEmpty));

                          if (!hasAddress) {
                            CustomSnackBar.showError(context,
                                "Cannot complete delivery: Address is missing");
                            return;
                          }

                          final otp = _otpCode;
                          if (otp.length != 4) {
                            CustomSnackBar.showError(context,
                                "Please enter the complete 4-digit code");
                            return;
                          }
                          await _verifyOtp();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(18)),
                    ),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? SizedBox(
                          width: R.w(24),
                          height: R.w(24),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Verify & Complete Delivery",
                          style: TextStyle(
                              fontSize: R.sp(16),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                        ),
                ),
              ),
              SizedBox(height: R.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}
