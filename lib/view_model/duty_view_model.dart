import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/model/duty_slot_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';

class DutyViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<DutySlot> _dutySlots = [];
  bool _isLoading = false;
  String? _error;
  DutySlot? _selectedSlot;

  List<DutySlot> get dutySlots => _dutySlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DutySlot? get selectedSlot => _selectedSlot;

  void setSelectedSlot(DutySlot? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> fetchDutySlots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dutySlots = await _apiService.getDutySlots();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startDuty(int slotId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In this app, updateAgentStatus(true) calls startDuty
      // We might need to modify updateAgentStatus to accept a slotId if the API requires it
      // But based on the provided info, we just need to fetch slots.
      // If the user wants to start duty with a specific slot, we'd need another API.
      // For now, I'll just implement the fetch logic as requested.
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
