class PartnerPerformanceModel {
  final bool status;
  final List<DailyPerformance> data;

  PartnerPerformanceModel({required this.status, required this.data});

  factory PartnerPerformanceModel.fromJson(Map<String, dynamic> json) {
    return PartnerPerformanceModel(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => DailyPerformance.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DailyPerformance {
  final String date;
  final int totalOrders;
  final double totalHours;

  DailyPerformance({
    required this.date,
    required this.totalOrders,
    required this.totalHours,
  });

  factory DailyPerformance.fromJson(Map<String, dynamic> json) {
    return DailyPerformance(
      date: json['date'] ?? '',
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyDutyLog {
  final String date;
  final num totalDutyTime;

  DailyDutyLog({
    required this.date,
    required this.totalDutyTime,
  });

  factory DailyDutyLog.fromJson(Map<String, dynamic> json) {
    return DailyDutyLog(
      date: json['date'] ?? '',
      totalDutyTime: json['totalDutyTime'] ?? 0,
    );
  }
}
