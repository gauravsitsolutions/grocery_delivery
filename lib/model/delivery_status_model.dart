class DeliveryStatus {
  final int totalOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int pendingOrders;

  DeliveryStatus({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.pendingOrders,
  });

  factory DeliveryStatus.fromJson(Map<String, dynamic> json) {
    return DeliveryStatus(
      totalOrders: json['total_orders'] ?? 0,
      deliveredOrders: json['delivered_orders'] ?? 0,
      cancelledOrders: json['cancelled_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
    );
  }
}

class DeliveryStatusResponse {
  final bool status;
  final DeliveryStatus? data;

  DeliveryStatusResponse({required this.status, this.data});

  factory DeliveryStatusResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusResponse(
      status: json['status'] == true || json['status'] == 'success',
      data: json['data'] != null ? DeliveryStatus.fromJson(json['data']) : null,
    );
  }
}
