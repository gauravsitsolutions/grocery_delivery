import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionStatusWrapper extends StatefulWidget {
  final Widget child;
  const ConnectionStatusWrapper({super.key, required this.child});

  @override
  State<ConnectionStatusWrapper> createState() => _ConnectionStatusWrapperState();
}

class _ConnectionStatusWrapperState extends State<ConnectionStatusWrapper> with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;
  bool _showOnlineBanner = false;
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
      begin: const Offset(0.0, -1.0),
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
      // Show Offline Banner immediately (Red)
       _animationController.forward();
       _showOnlineBanner = false;
       _onlineBannerTimer?.cancel();
    } else {
      // Just came back online
      // Show Online Banner (Green) for a few seconds
      setState(() {
        _showOnlineBanner = true;
      });
      _animationController.forward();

      // Ensure animation stays for a bit, then hide
      _onlineBannerTimer?.cancel();
      _onlineBannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
           _animationController.reverse().then((_) {
             if (mounted) {
               setState(() {
                 _showOnlineBanner = false;
               });
             }
           });
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
        SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 5,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                color: _isOffline 
                  ? Colors.red 
                  : (_showOnlineBanner ? Colors.green : Colors.transparent),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOffline ? Icons.wifi_off : Icons.wifi,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isOffline ? 'No Internet Connection' : 'Back Online',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
