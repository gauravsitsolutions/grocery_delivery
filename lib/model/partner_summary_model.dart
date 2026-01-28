class PartnerStats {
  final int totalOrdersToday;
  final int deliveredOrders;
  final double earningsToday;

  PartnerStats({
    required this.totalOrdersToday,
    required this.deliveredOrders,
    required this.earningsToday,
  });

  factory PartnerStats.fromJson(Map<String, dynamic> json) {
    return PartnerStats(
      totalOrdersToday: json['totalOrdersToday'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      earningsToday: (json['earningsToday'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PartnerStats.empty() {
    return PartnerStats(
      totalOrdersToday: 0,
      deliveredOrders: 0,
      earningsToday: 0.0,
    );
  }
}

class PartnerSummary {
  final String? name;
  final String? imageUrl;
  final String? dutyStatus;
  final int totalDutyTime;
  final int todayDutyTime;
  final PartnerStats? stats;

  PartnerSummary({
    this.name,
    this.imageUrl,
    this.dutyStatus,
    required this.totalDutyTime,
    required this.todayDutyTime,
    this.stats,
  });

  factory PartnerSummary.fromJson(Map<String, dynamic> json) {
    // Check if 'data' exists, otherwise use json itself (handling flat structure)
    final data =
        json['data'] != null ? json['data'] as Map<String, dynamic> : json;

    String? status = data['duty_status'];
    if (status == null) {
      // Infer from isOnline if available
      if (data['isOnline'] == true) {
        status = 'online';
      } else if (data['isOnline'] == false) {
        status = 'offline';
      }
    }

    // Handle todayDutyTime - convert to positive int (seconds)
    int validDutyTime = 0;
    if (data['todayDutyTime'] != null) {
      // It comes as a negative float sometimes, e.g. -7428.619
      double rawTime = (data['todayDutyTime'] as num).toDouble();
      validDutyTime = rawTime.abs().toInt();
    }

    return PartnerSummary(
      name: data['name'],
      imageUrl: data['imageUrl'],
      dutyStatus: status,
      totalDutyTime: (data['totalDutyTime'] as num?)?.toInt() ?? 0,
      todayDutyTime: validDutyTime,
      stats: data['stats'] != null
          ? PartnerStats.fromJson(data['stats'])
          : PartnerStats.empty(),
    );
  }
}
