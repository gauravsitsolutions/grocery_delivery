import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
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

    setState(() {
      _isOffline = isNone;
    });

    if (_isOffline) {
      // Show Offline Banner (Red)
      _animationController.forward();
      // Hide after 3 seconds
      _onlineBannerTimer?.cancel();
      _onlineBannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController.reverse();
        }
      });
    } else {
      // Show Online Banner (Green)
      _animationController.forward();

      // Hide after 3 seconds
      _onlineBannerTimer?.cancel();
      _onlineBannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _animationController.reverse();
        }
      });
    }
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
            child: Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 20,
                right: 20,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isOffline ? AppColors.error : AppColors.success,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOffline ? Icons.wifi_off : Icons.wifi,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isOffline ? 'No Internet Connection' : 'Back Online',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
