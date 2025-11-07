import 'package:flutter/material.dart';
import 'package:photo_momento/domain/repositories/order_repository.dart';
import 'package:photo_momento/data/models/order_model.dart';
import 'package:photo_momento/data/repositories/order_repository_impl.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository;

  OrderProvider({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepositoryImpl();

  List<OrderModel> _orders = [];
  List<OrderModel> _allOrders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  OrderStatus? _currentFilter;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get allOrders => _allOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get currentFilter => _currentFilter;

  // Load user orders
  Future<void> loadUserOrders(String userId) async {
    try {
      _setLoading(true);
      _orders = await _orderRepository.getUserOrders(userId);
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Siparişler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load all orders (for admin)
  Future<void> loadAllOrders({OrderStatus? status}) async {
    try {
      _setLoading(true);
      _currentFilter = status;
      _allOrders = await _orderRepository.getAllOrders(status: status);
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Tüm siparişler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Create new order
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      _setLoading(true);
      final newOrder = await _orderRepository.createOrder(order);
      _error = null;

      // Add to local list
      _orders.insert(0, newOrder);
      notifyListeners();

      return newOrder;
    } on OrderException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = 'Sipariş oluşturulurken bir hata oluştu: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updatedOrder = await _orderRepository.updateOrderStatus(orderId, status);

      // Update local state
      _updateOrderInList(updatedOrder);
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Sipariş durumu güncellenirken bir hata oluştu: $e';
      notifyListeners();
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _orderRepository.cancelOrder(orderId);

      // Update local state
      final order = _orders.firstWhere((o) => o.id == orderId);
      final updatedOrder = order.copyWith(status: OrderStatus.cancelled);
      _updateOrderInList(updatedOrder);
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Sipariş iptal edilirken bir hata oluştu: $e';
      notifyListeners();
    }
  }

  // Get single order
  Future<void> loadOrder(String orderId) async {
    try {
      _setLoading(true);
      _selectedOrder = await _orderRepository.getOrder(orderId);
      _error = null;
    } on OrderException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Sipariş yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get all orders by status (admin)
  List<OrderModel> getAllOrdersByStatus(OrderStatus status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  // Get pending orders count
  int get pendingOrdersCount {
    return _orders.where((order) => order.status == OrderStatus.pending).length;
  }

  // Get total orders count
  int get totalOrdersCount => _orders.length;

  // Get total revenue (admin)
  double get totalRevenue {
    return _allOrders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0, (sum, order) => sum + order.total);
  }

  // Initialize stream for real-time updates
  void initializeUserOrdersStream(String userId) {
    _orderRepository.streamUserOrders(userId).listen(
          (orders) {
        _orders = orders;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Siparişler dinlenirken bir hata oluştu: $error';
        notifyListeners();
      },
    );
  }

  // Initialize admin orders stream
  void initializeAllOrdersStream({OrderStatus? status}) {
    _orderRepository.streamAllOrders(status: status).listen(
          (orders) {
        _allOrders = orders;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Tüm siparişler dinlenirken bir hata oluştu: $error';
        notifyListeners();
      },
    );
  }

  // Helper method to update order in local list
  void _updateOrderInList(OrderModel updatedOrder) {
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }

    final allIndex = _allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (allIndex != -1) {
      _allOrders[allIndex] = updatedOrder;
      notifyListeners();
    }

    if (_selectedOrder?.id == updatedOrder.id) {
      _selectedOrder = updatedOrder;
      notifyListeners();
    }
  }

  // Filter orders by date range
  List<OrderModel> filterOrdersByDateRange(DateTime start, DateTime end) {
    return _allOrders.where((order) {
      return order.createdAt.isAfter(start) && order.createdAt.isBefore(end);
    }).toList();
  }

  // Search orders by customer name or email
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return _allOrders;

    final searchLower = query.toLowerCase();
    return _allOrders.where((order) {
      return order.customerName.toLowerCase().contains(searchLower) ||
          order.customerEmail.toLowerCase().contains(searchLower) ||
          order.formattedOrderNumber.toLowerCase().contains(searchLower);
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Set selected order
  void setSelectedOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}