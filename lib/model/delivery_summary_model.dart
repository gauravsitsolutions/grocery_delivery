class DeliverySummary {
  final int totalDeliveries;
  final double totalEarnings; // Assuming earnings are part of summary
  final double totalDistance; // Assuming distance is part of summary
  final int totalDurationHours; // Assuming duration is part of summary

  DeliverySummary({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.totalDistance,
    required this.totalDurationHours,
  });

  factory DeliverySummary.fromJson(Map<String, dynamic> json) {
    return DeliverySummary(
      totalDeliveries: json['total_deliveries'] ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      totalDurationHours: (json['total_duration_hours'] as num?)?.toInt() ?? 0,
    );
  }
}
