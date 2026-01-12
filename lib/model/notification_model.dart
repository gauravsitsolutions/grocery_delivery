class NotificationResponse {
  final bool status;
  final List<NotificationModel> data;
  final int? currentPage;
  final int? lastPage;
  final int? total;

  NotificationResponse({
    required this.status,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<NotificationModel> notifications = [];
    int? current;
    int? last;
    int? totalCount;

    if (rawData is Map) {
      if (rawData['data'] is List) {
        notifications = (rawData['data'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
      current = rawData['current_page'];
      last = rawData['last_page'];
      totalCount = rawData['total'];
    }

    return NotificationResponse(
      status: json['status'] == true || json['status'] == 'success',
      data: notifications,
      currentPage: current,
      lastPage: last,
      total: totalCount,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? type;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Handle Laravel standard notification structure vs flattened API response
    final data = json['data'] is Map ? json['data'] : {};

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: data['title']?.toString() ??
          json['title']?.toString() ??
          'Notification',
      message: data['message']?.toString() ?? json['message']?.toString() ?? '',
      type: json['type']?.toString(),
      createdAt: _parseDate(json['created_at']),
      readAt: json['read_at'] != null ? _parseDate(json['read_at']) : null,
    );
  }

  bool get isRead => readAt != null;

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
