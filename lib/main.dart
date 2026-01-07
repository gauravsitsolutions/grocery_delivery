import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/connection_status_wrapper.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_page.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/view/splash_view.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view_model/auth_view_model.dart';
import 'res/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppPages.routes,
        builder: (context, child) => ConnectionStatusWrapper(
          child: ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
              Breakpoint(start: 801, end: 1920, name: DESKTOP),
            ],
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
