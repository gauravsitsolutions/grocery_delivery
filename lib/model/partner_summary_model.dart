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

    return PartnerSummary(
      name: data['name'],
      imageUrl: data['imageUrl'],
      dutyStatus: status,
      totalDutyTime: (data['totalDutyTime'] as num?)?.toInt() ?? 0,
      todayDutyTime: (data['todayDutyTime'] as num?)?.toInt() ?? 0,
    );
  }
}
