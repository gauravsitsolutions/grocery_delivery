import 'package:samrudhi_delivery_agent_app/model/order_model.dart';

class DeliveryHistoryResponse {
  final bool status;
  final DeliveryHistorySummary summary;
  final List<Order> inProgress; // Response has inProgress array
  final OrderResponse deliveries; // The paginated list

  DeliveryHistoryResponse({
    required this.status,
    required this.summary,
    required this.inProgress,
    required this.deliveries,
  });

  factory DeliveryHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryHistoryResponse(
      status: json['status'] == true,
      summary: json['summary'] != null
          ? DeliveryHistorySummary.fromJson(json['summary'])
          : DeliveryHistorySummary.empty(),
      inProgress: json['inProgress'] is List
          ? (json['inProgress'] as List).map((e) => Order.fromJson(e)).toList()
          : [],
      deliveries: json['deliveries'] != null
          ? OrderResponse.fromJson({'data': json['deliveries'], 'status': true})
          : OrderResponse(status: true, data: []),
    );
  }
}

class DeliveryHistorySummary {
  final int total;
  final int completed;
  final int cancelled;

  DeliveryHistorySummary({
    required this.total,
    required this.completed,
    required this.cancelled,
  });

  factory DeliveryHistorySummary.fromJson(Map<String, dynamic> json) {
    return DeliveryHistorySummary(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }

  factory DeliveryHistorySummary.empty() {
    return DeliveryHistorySummary(total: 0, completed: 0, cancelled: 0);
  }
}
