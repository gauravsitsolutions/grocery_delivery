import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class ConnectionStatusWrapper extends StatefulWidget {
  final Widget child;
  const ConnectionStatusWrapper({super.key, required this.child});

  @override
  State<ConnectionStatusWrapper> createState() =>
      _ConnectionStatusWrapperState();
}

class _ConnectionStatusWrapperState extends State<ConnectionStatusWrapper>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  Timer? _onlineBannerTimer;

  // Animation for sliding the banner in/out
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5), // Start a bit lower
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // More premium feel
    ));

    // Initial check
    _checkInitialStatus();

    // Listen to changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    bool isNone = results.contains(ConnectivityResult.none);

    // Avoid redrawing if status hasn't changed effectively
    if (_isOffline == isNone) return;

    if (mounted) {
      setState(() {
        _isOffline = isNone;
      });
    }

    // Always show transition when status changes
    _animationController.forward();

    // Hide after 4 seconds for a better reading time
    _onlineBannerTimer?.cancel();
    _onlineBannerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _onlineBannerTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: R.w(20),
                  vertical: R.h(20),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(20), vertical: R.h(16)),
                decoration: BoxDecoration(
                  color: _isOffline
                      ? const Color(0xFF1E1E1E)
                      : AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(R.r(24)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isOffline ? Colors.black : AppColors.primaryGreen)
                              .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.w(8)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isOffline
                            ? RemixIcons.wifi_off_line
                            : RemixIcons.wifi_line,
                        color: AppColors.white,
                        size: R.sp(18),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Text(
                      _isOffline ? 'No Internet Connection' : 'Back Online!',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(15),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
