class PartnerSummary {
  final String? name;
  final String? imageUrl;
  final String? dutyStatus;
  final int totalDutyTime;
  final int todayDutyTime;

  PartnerSummary({
    this.name,
    this.imageUrl,
    this.dutyStatus,
    required this.totalDutyTime,
    required this.todayDutyTime,
  });

  factory PartnerSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PartnerSummary(
      name: data['name'],
      imageUrl: data['imageUrl'],
      dutyStatus: data['duty_status'] ??
          data['status'], // Handling potential key variations from API
      totalDutyTime: (data['totalDutyTime'] as num?)?.toInt() ?? 0,
      todayDutyTime: (data['todayDutyTime'] as num?)?.toInt() ?? 0,
    );
  }
}
