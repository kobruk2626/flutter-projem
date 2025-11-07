import 'package:photo_momento/data/models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getUserOrders(String userId);
  Future<List<OrderModel>> getAllOrders({OrderStatus? status});
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder(String orderId);
  Future<OrderModel> getOrder(String orderId);
  Stream<List<OrderModel>> streamUserOrders(String userId);
  Stream<List<OrderModel>> streamAllOrders({OrderStatus? status});
}