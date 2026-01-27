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
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';
import 'package:samrudhi_delivery_agent_app/widget/agent_bottom_nav_item.dart';

import 'package:samrudhi_delivery_agent_app/view/splash_view.dart';

import 'app_routes.dart';

import 'package:animations/animations.dart';

class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case AppRoutes.splash:
        page = const SplashScreen();
        break;
      case AppRoutes.login:
        page = const LoginView();
        break;
      case AppRoutes.forgotPassword:
        page = const ForgotPasswordView();
        break;
      case AppRoutes.forgotPasswordOtp:
        page = const ForgotPasswordOTPView();
        break;
      case AppRoutes.setNewPassword:
        page = const SetNewPasswordView();
        break;
      case AppRoutes.passwordResetSuccess:
        page = const PasswordResetSuccessView();
        break;
      case AppRoutes.bottomNav:
        page = const AgentBottomNavView();
        break;
      case AppRoutes.dashboard:
        page = AgentDashboardView(
          isOnline: true,
          onStatusChanged: (_) {},
        );
        break;
      case AppRoutes.customerInfo:
        page = const CustomerInfoView();
        break;
      case AppRoutes.deliverySummary:
        page = const DeliverySummaryView();
        break;
      case AppRoutes.navigationView:
        page = const NavigationView();
        break;
      case AppRoutes.verificationView:
        page = const VerificationView();
        break;
      case AppRoutes.notificationView:
        page = const NotificationsView();
        break;
      case AppRoutes.orderDetails:
        final args = settings.arguments;
        if (args is int) {
          page = OrderDetailsView(orderId: args);
        } else {
          try {
            final dynamic order = args;
            page = OrderDetailsView(orderId: order.id, order: order);
          } catch (_) {
            page = const OrderDetailsView(orderId: 0); // Error fallback
          }
        }
        break;
      default:
        page = const SplashScreen(); // Fallback
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
