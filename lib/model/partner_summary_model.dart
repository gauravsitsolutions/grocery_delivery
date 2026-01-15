class PartnerSummary {
  final String? name;
  final String? imageUrl;
  final int totalDutyTime;
  final int todayDutyTime;

  PartnerSummary({
    this.name,
    this.imageUrl,
    required this.totalDutyTime,
    required this.todayDutyTime,
  });

  factory PartnerSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PartnerSummary(
      name: data['name'],
      imageUrl: data['imageUrl'],
      totalDutyTime: (data['totalDutyTime'] as num?)?.toInt() ?? 0,
      todayDutyTime: (data['todayDutyTime'] as num?)?.toInt() ?? 0,
    );
  }
}
