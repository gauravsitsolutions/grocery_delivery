import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_page.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/view_model/auth_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'res/theme/app_theme.dart';

import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/connection_status_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OrderListViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme, // Removed to avoid premature access
      initialRoute: AppRoutes.splash,
      routes: AppPages.routes,
      builder: (context, child) {
        R.init(context);
        return ConnectionStatusWrapper(
          child: Theme(
            data: AppTheme.lightTheme,
            child: ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1920, name: DESKTOP),
              ],
            ),
          ),
        );
      },
    );
  }
}
