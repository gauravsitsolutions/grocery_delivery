import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/forgot_password_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/otp_verification_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/password_reset_success_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/set_new_password_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/login/login_view.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/customer_info/customer_info_view.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_summary/delivery_completed_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';
import 'package:samrudhi_delivery_agent_app/view/notification_settings/notification_settings_view.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';
import 'package:samrudhi_delivery_agent_app/widget/agent_bottom_nav_item.dart';

import 'package:samrudhi_delivery_agent_app/view/splash_view.dart';

import 'app_routes.dart';

class AppPages {
  static final Map<String, WidgetBuilder> routes = {
    // Auth
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.login: (_) => const LoginView(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordView(),
    AppRoutes.forgotPasswordOtp: (_) => const ForgotPasswordOTPView(),
    AppRoutes.setNewPassword: (_) => const SetNewPasswordView(),
    AppRoutes.passwordResetSuccess: (_) => const PasswordResetSuccessView(),

    // Main
    AppRoutes.bottomNav: (_) => const AgentBottomNavView(),
    AppRoutes.dashboard: (_) => AgentDashboardView(
          isOnline: true,
          onStatusChanged: (_) {},
        ),
    AppRoutes.customerInfo: (_) => const CustomerInfoView(),
    AppRoutes.notification: (_) => const NotificationsView(),
    AppRoutes.notificationSettings: (_) => const NotificationSettingsView(),
    AppRoutes.deliverySummary: (_) => const DeliverySummaryView(),
    AppRoutes.navigationView: (_) => const NavigationView(),
    AppRoutes.verificationView: (_) => const VerificationView(),
    AppRoutes.orderDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        return OrderDetailsView(orderId: args);
      }
      // Assuming args is Order object (dynamic check effectively)
      // Since we don't have Order type imported here easily without check, let's assume strict passing
      // But we can check dynamic
      try {
        final dynamic order = args;
        return OrderDetailsView(orderId: order.id, order: order);
      } catch (_) {
        return const OrderDetailsView(orderId: 0); // Error fallback
      }
    },
  };
}
