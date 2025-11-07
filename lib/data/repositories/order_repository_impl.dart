import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_momento/domain/repositories/order_repository.dart';
import 'package:photo_momento/data/models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final docRef = _firestore.collection('orders').doc();
      final orderWithId = order.copyWith(id: docRef.id);

      await docRef.set(orderWithId.toFirestore());

      return orderWithId;
    } catch (e) {
      throw OrderException('Sipariş oluşturulurken hata oluştu: $e');
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw OrderException('Siparişler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders({OrderStatus? status}) async {
    try {
      Query query = _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw OrderException('Siparişler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final doc = await _firestore.collection('orders').doc(orderId).get();
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw OrderException('Sipariş durumu güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw OrderException('Sipariş iptal edilirken hata oluştu: $e');
    }
  }

  @override
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList());
  }
}

class OrderException implements Exception {
  final String message;
  OrderException(this.message);

  @override
  String toString() => message;
}

extension OrderModelCopyWith on OrderModel {
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
}