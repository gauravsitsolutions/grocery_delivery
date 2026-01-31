import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/forgot_password_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/otp_verification_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/password_reset_success_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/forgot_password/set_new_password_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/login/login_view.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/customer_info/customer_info_view.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_summary/delivery_completed_view.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_history/delivery_history_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
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
        final dynamic args = settings.arguments;
        if (args is int) {
          page = CustomerInfoView(orderId: args);
        } else if (args != null) {
          try {
            page = CustomerInfoView(orderId: args.id, order: args);
          } catch (_) {
            page = const CustomerInfoView();
          }
        } else {
          page = const CustomerInfoView();
        }
        break;
      case AppRoutes.deliverySummary:
        final dynamic args = settings.arguments;
        if (args is Order) {
          page = DeliveryCompletedView(order: args);
        } else {
          page = const DeliveryCompletedView();
        }
        break;
      case AppRoutes.deliveryHistory:
        page = const DeliveryHistoryView();
        break;
      case AppRoutes.navigationView:
        final dynamic args = settings.arguments;
        if (args is int) {
          page = NavigationView(orderId: args);
        } else if (args != null) {
          try {
            page = NavigationView(orderId: args.id, order: args);
          } catch (_) {
            page = const NavigationView();
          }
        } else {
          page = const NavigationView();
        }
        break;
      case AppRoutes.verificationView:
        final dynamic args = settings.arguments;
        if (args is int) {
          page = VerificationView(orderId: args);
        } else if (args != null) {
          try {
            page = VerificationView(orderId: args.id, order: args);
          } catch (_) {
            page = const VerificationView();
          }
        } else {
          page = const VerificationView();
        }
        break;
      case AppRoutes.notificationView:
        page = const NotificationsView();
        break;
      case AppRoutes.pickupTask:
        final args = settings.arguments;
        if (args is int) {
          page = PickupTaskView(orderId: args);
        } else {
          try {
            final dynamic order = args;
            page = PickupTaskView(orderId: order.id, order: order);
          } catch (_) {
            page = const PickupTaskView(orderId: 0); // Error fallback
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
