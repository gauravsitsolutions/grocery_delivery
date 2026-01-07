import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class ConnectionStatusWrapper extends StatelessWidget {
  final Widget child;

  const ConnectionStatusWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data;


        // However, onConnectivityChanged can emit multiple results (e.g. [mobile, vpn]).
        // If ANY is mobile, wifi, ethernet, bluetooth, then we are connected.
        bool hasConnection = results != null && results.any((result) => 
            result == ConnectivityResult.mobile || 
            result == ConnectivityResult.wifi || 
            result == ConnectivityResult.ethernet);

        // If snapshot has data and we definitely have NO connection methods:
        if (snapshot.hasData && !hasConnection) {
          return Stack(
            children: [
              child,
              Container(
                color: Colors.white, // Or a semi-transparent overlay
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/no_internet.json',
                        width: R.w(200),
                        height: R.h(200),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                           return Icon(Icons.wifi_off, size: R.sp(100), color: Colors.grey);
                        },
                      ),
                      SizedBox(height: R.h(20)),
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none, // Inherited from Container/No Material
                        ),
                      ),
                      SizedBox(height: R.h(10)),
                      Text(
                        'Please check your mobile data or Wi-Fi.',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return child;
      },
    );
  }
}
