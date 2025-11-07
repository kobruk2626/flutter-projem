class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final int totalOrders;
  final double totalSpent;
  final double rating;
  final DateTime registeredAt;
  final DateTime? lastOrderAt;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.totalOrders,
    required this.totalSpent,
    required this.rating,
    required this.registeredAt,
    this.lastOrderAt,
    required this.isActive,
  });

  bool get isNew => DateTime.now().difference(registeredAt).inDays <= 7;

  bool get isLoyal => totalOrders >= 5 && rating >= 4.5;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      city: json['city'],
      totalOrders: json['total_orders'] ?? 0,
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      registeredAt: DateTime.parse(json['registered_at']),
      lastOrderAt: json['last_order_at'] != null
          ? DateTime.parse(json['last_order_at'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }
}