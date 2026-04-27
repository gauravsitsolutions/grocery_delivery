class DutySlotModel {
  final bool status;
  final String message;
  final List<DutySlot> data;

  DutySlotModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DutySlotModel.fromJson(Map<String, dynamic> json) {
    return DutySlotModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<DutySlot>.from(json['data'].map((x) => DutySlot.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class DutySlot {
  final int id;
  final String label;
  final String startTime;
  final String endTime;
  final String display;

  DutySlot({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.display,
  });

  factory DutySlot.fromJson(Map<String, dynamic> json) {
    return DutySlot(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'start_time': startTime,
      'end_time': endTime,
      'display': display,
    };
  }

  bool get isExpired {
    if (endTime.isEmpty) return false;
    try {
      final now = DateTime.now();
      final parts = endTime.split(':');
      if (parts.length != 2) return false;

      final endDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      return now.isAfter(endDateTime);
    } catch (e) {
      return false;
    }
  }
}
