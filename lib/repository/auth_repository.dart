import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/data/network/base_api_service.dart';
import 'package:samrudhi_delivery_agent_app/data/network/network_api_service.dart';

class AuthRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response =
          await _apiService.getPostApiResponse(AppUrl.loginWithEmail, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
