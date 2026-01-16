import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo
  late Animation<double> _logoScale;

  // App name
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;

  // Feature row
  late Animation<Offset> _featuresSlide;
  late Animation<double> _featuresFade;

  bool _showCenterLoader = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Logo hover
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // App name
    _titleSlide = _slide(0.30, 0.45);
    _titleFade = _fade(0.30, 0.45);

    // Feature row (same animation type, later)
    _featuresSlide = _slide(0.60, 0.80);
    _featuresFade = _fade(0.60, 0.80);

    // Listen when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationCompleted();
      }
    });

    _controller.forward();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  Animation<Offset> _slide(double start, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<double> _fade(double start, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _onAnimationCompleted() async {
    // Show centered loader
    if (mounted) {
      setState(() {
        _showCenterLoader = true;
      });
    }

    // Keep loader for few seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // RESTORE STATUS BAR EXPLICITLY
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values, // This brings back Status Bar + Nav Bar
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Check for saved session
    final token = await SharedPrefsUtil.getToken();

    debugPrint('Splash: Saved Token found: $token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      debugPrint('Splash: Navigating to Dashboard (Session Valid)');
      Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
    } else {
      debugPrint('Splash: Navigating to Login (No Session)');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// CONTENT
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// LOGO
              ScaleTransition(
                scale: _logoScale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    height: R.w(170),
                    width: R.w(170),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: R.h(40)),

              /// APP NAME
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.primaryGreen],
                    ).createShader(bounds),
                    child: Text(
                      'Samruddha Kirana',
                      style: TextStyle(
                        fontSize: R.sp(30),
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.h(60)),

              /// FEATURES ROW
              FadeTransition(
                opacity: _featuresFade,
                child: SlideTransition(
                  position: _featuresSlide,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _FeatureItem(
                        icon: Icons.local_shipping,
                        text: 'Fast\nDelivery',
                      ),
                      _FeatureItem(
                        icon: Icons.security,
                        text: 'Secure\nPayments',
                      ),
                      _FeatureItem(
                        icon: Icons.verified,
                        text: 'Quality\nProducts',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// CENTER LOADER (AFTER ALL ANIMATIONS)
          if (_showCenterLoader)
            const IgnorePointer(
              ignoring: true,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ),
            ),

          /// VERSION NUMBER (BOTTOM)
          Positioned(
            bottom: R.h(40),
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Version $_version',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(R.w(12)),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.blue, size: R.sp(22)),
        ),
        SizedBox(height: R.h(8)),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blue,
            fontSize: R.sp(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
