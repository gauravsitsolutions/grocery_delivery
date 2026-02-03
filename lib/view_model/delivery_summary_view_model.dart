import 'package:flutter/foundation.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';

class DeliverySummaryViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DeliverySummary? _summary;
  bool _isLoading = false;
  String? _error;

  DeliverySummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSummary({
    String dateRange = 'today',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? fromDateStr;
      String? toDateStr;

      if (dateRange == 'custom' && fromDate != null && toDate != null) {
        fromDateStr = fromDate.toIso8601String().split('T').first;
        toDateStr = toDate.toIso8601String().split('T').first;
      }

      _summary = await _apiService.getDeliverySummary(
        dateRange: dateRange,
        fromDate: fromDateStr,
        toDate: toDateStr,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
