import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/repository/auth_repository.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/utils.dart';

import 'package:samrudhi_delivery_agent_app/model/login_model.dart';
import 'dart:developer';

class AuthViewModel with ChangeNotifier {
  final _myRepo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<bool> loginApi(dynamic data, BuildContext context) async {
    setLoading(true);

    try {
      final value = await _myRepo.loginApi(data);
      final response = LoginResponseModel.fromJson(value);
      // Check Step 442: I merged them. The class name LoginResponseModel still exists in the file, but I should check what I'm using.
      // In step 438, LoginResponseModel was defined. In step 442 I merged them.
      // Let's verify the class name in login_model.dart.
      // I wrote: class LoginModel... and class LoginResponseModel... in step 442.
      // So LoginResponseModel CLASS still exists.
      
      setLoading(false);
      if (!context.mounted) return false;
      Utils.flushBarErrorMessage('Login Successful: ${response.message}', context);
      Navigator.pushNamed(context, AppRoutes.bottomNav);
      if (kDebugMode) {
        log("Token: ${response.token}");
        log("User: ${response.user?.name}");
      }
      return true;
    } catch (error) {
      setLoading(false);
      if (!context.mounted) return false;
      Utils.flushBarErrorMessage(error.toString(), context);
      if (kDebugMode) {
        log(error.toString());
      }
      return false;
    }
  }
}
