class CancellationReason {
  final int id;
  final String reason;

  CancellationReason({
    required this.id,
    required this.reason,
  });

  factory CancellationReason.fromJson(Map<String, dynamic> json) {
    return CancellationReason(
      id: json['id'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
    };
  }
}
