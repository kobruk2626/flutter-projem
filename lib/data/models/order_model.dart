import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:photo_momento/data/models/user_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Address deliveryAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentMethod? paymentMethod;
  final String? shippingTrackingNumber;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final List<String> imageUrls; // Müşterinin yüklediği fotoğraflar
  final String? specialNote;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    this.discount = 0,
    required this.total,
    required this.status,
    this.paymentMethod,
    this.shippingTrackingNumber,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveredAt,
    this.imageUrls = const [],
    this.specialNote,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      deliveryAddress: Address.fromMap(data['deliveryAddress'] ?? {}),
      items: (data['items'] as List? ?? []).map((e) => OrderItem.fromMap(e)).toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: data['paymentMethod'] != null
          ? PaymentMethod.fromMap(data['paymentMethod'])
          : null,
      shippingTrackingNumber: data['shippingTrackingNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      estimatedDelivery: data['estimatedDelivery'] != null
          ? (data['estimatedDelivery'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      specialNote: data['specialNote'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress.toMap(),
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'discount': discount,
      'total': total,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod?.toMap(),
      'shippingTrackingNumber': shippingTrackingNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'imageUrls': imageUrls,
      'specialNote': specialNote,
    };
  }

  // CopyWith metodu
  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    Address? deliveryAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? shippingCost,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? shippingTrackingNumber,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    DateTime? deliveredAt,
    List<String>? imageUrls,
    String? specialNote,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingTrackingNumber: shippingTrackingNumber ?? this.shippingTrackingNumber,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      imageUrls: imageUrls ?? this.imageUrls,
      specialNote: specialNote ?? this.specialNote,
    );
  }

  String get formattedOrderNumber => '#${id.substring(0, 8).toUpperCase()}';
  String get formattedTotal => '${total.toStringAsFixed(2)}₺';
  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canTrack => status == OrderStatus.shipped;

  // Durum metni
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Beklemede';
      case OrderStatus.confirmed:
        return 'Onaylandı';
      case OrderStatus.processing:
        return 'İşleniyor';
      case OrderStatus.printing:
        return 'Baskıda';
      case OrderStatus.ready:
        return 'Hazır';
      case OrderStatus.shipped:
        return 'Kargoda';
      case OrderStatus.delivered:
        return 'Teslim Edildi';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
      case OrderStatus.refunded:
        return 'İade Edildi';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String size;
  final String paperType;
  final double price;
  final int quantity;
  final List<String> imageUrls; // Bu ürün için seçilen fotoğraflar

  OrderItem({
    required this.productId,
    required this.productName,
    required this.size,
    required this.paperType,
    required this.price,
    required this.quantity,
    this.imageUrls = const [],
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      size: map['size'] ?? '',
      paperType: map['paperType'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'size': size,
      'paperType': paperType,
      'price': price,
      'quantity': quantity,
      'imageUrls': imageUrls,
    };
  }

  double get total => price * quantity;
  String get formattedPrice => '${price.toStringAsFixed(2)}₺';
  String get formattedTotal => '${total.toStringAsFixed(2)}₺';
}

enum OrderStatus {
  pending,      // Beklemede
  confirmed,    // Onaylandı
  processing,   // İşleniyor
  printing,     // Baskıda
  ready,        // Hazır
  shipped,      // Kargoda
  delivered,    // Teslim edildi
  cancelled,    // İptal edildi
  refunded,     // İade edildi
}