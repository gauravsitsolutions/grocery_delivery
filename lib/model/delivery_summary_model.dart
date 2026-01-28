class DeliverySummary {
  final int completedCount;
  final double totalDistanceKm;
  final double avgDeliveryTimeMin;

  DeliverySummary({
    required this.completedCount,
    required this.totalDistanceKm,
    required this.avgDeliveryTimeMin,
  });

  factory DeliverySummary.fromJson(Map<String, dynamic> json) {
    return DeliverySummary(
      completedCount: json['completedCount'] ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      avgDeliveryTimeMin:
          (json['avgDeliveryTimeMin'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
