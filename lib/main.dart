import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_page.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/view/splash_view.dart';
import 'res/theme/app_theme.dart';

import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme, // Removed to avoid premature access
      initialRoute: AppRoutes.login,
      routes: AppPages.routes,
      builder: (context, child) {
        R.init(context);
        return Theme(
          data: AppTheme.lightTheme,
          child: ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
              Breakpoint(start: 801, end: 1920, name: DESKTOP),
            ],
          ),
        );
      },
      home: SplashScreen(),
    );
  }
}
