class NotificationModel {
  final String id;
  final String orderId;
  final String customerId;
  final String type;
  final String channel;
  final String status;
  final String message;
  final String? errorMessage;
  final DateTime sentAt;
  final DateTime? deliveredAt;

  NotificationModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.type,
    required this.channel,
    required this.status,
    required this.message,
    this.errorMessage,
    required this.sentAt,
    this.deliveredAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      type: json['type'],
      channel: json['channel'],
      status: json['status'],
      message: json['message'],
      errorMessage: json['error_message'],
      sentAt: DateTime.parse(json['sent_at']),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'type': type,
      'channel': channel,
      'status': status,
      'message': message,
      'error_message': errorMessage,
      'sent_at': sentAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}