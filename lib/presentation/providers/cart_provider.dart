import 'package:flutter/material.dart';
import 'package:photo_momento/data/models/order_model.dart';
import 'package:photo_momento/data/models/product_model.dart';
import 'package:photo_momento/data/models/user_model.dart';
import 'package:photo_momento/core/constants/app_constants.dart';

class CartProvider with ChangeNotifier {
  final List<OrderItem> _items = [];
  Address? _selectedAddress;
  PaymentMethod? _selectedPaymentMethod;
  String? _specialNote;

  List<OrderItem> get items => _items;
  Address? get selectedAddress => _selectedAddress;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get specialNote => _specialNote;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get shippingCost => subtotal >= AppConstants.freeShippingThreshold ? 0 : AppConstants.standardShippingCost;
  double get total => subtotal + shippingCost;

  void addToCart(ProductModel product, int quantity, List<String> imageUrls) {
    final existingIndex = _items.indexWhere(
          (item) => item.productId == product.id &&
          item.size == product.size &&
          item.paperType == product.paperType,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(OrderItem(
        productId: product.id,
        productName: product.name,
        size: product.size,
        paperType: product.paperType,
        price: product.price,
        quantity: quantity,
        imageUrls: imageUrls,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void updateSelectedPaymentMethod(PaymentMethod paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  void updateSpecialNote(String note) {
    _specialNote = note;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedAddress = null;
    _selectedPaymentMethod = null;
    _specialNote = null;
    notifyListeners();
  }

  bool get isCartValid {
    return _items.isNotEmpty &&
        _selectedAddress != null &&
        _selectedPaymentMethod != null;
  }

  OrderModel createOrder(String userId, String customerName, String customerEmail, String customerPhone) {
    // Tüm fotoğraf URL'lerini topla
    final allImageUrls = _items.expand((item) => item.imageUrls).toList();

    return OrderModel(
      id: '', // Will be set by repository
      userId: userId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      deliveryAddress: _selectedAddress!,
      items: List.from(_items),
      subtotal: subtotal,
      shippingCost: shippingCost,
      discount: 0,
      total: total,
      status: OrderStatus.pending,
      paymentMethod: _selectedPaymentMethod,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(Duration(days: AppConstants.estimatedDeliveryDays)),
      imageUrls: allImageUrls,
      specialNote: _specialNote,
    );
  }

  // Sepetteki belirli bir ürünün miktarını getir
  int getProductQuantity(ProductModel product) {
    final item = _items.firstWhere(
          (item) => item.productId == product.id &&
          item.size == product.size &&
          item.paperType == product.paperType,
      orElse: () => OrderItem(
        productId: product.id,
        productName: product.name,
        size: product.size,
        paperType: product.paperType,
        price: product.price,
        quantity: 0,
        imageUrls: [],
      ),
    );
    return item.quantity;
  }

  // Sepetteki toplam ürün sayısını getir (farklı ürünler)
  int get distinctItemCount => _items.length;

  // Sepet boş mu?
  bool get isEmpty => _items.isEmpty;

  // Sepet dolu mu?
  bool get isNotEmpty => _items.isNotEmpty;

  // Ücretsiz kargo için kalan tutarı hesapla
  double get remainingForFreeShipping {
    final remaining = AppConstants.freeShippingThreshold - subtotal;
    return remaining > 0 ? remaining : 0;
  }

  // Ücretsiz kargo için yüzde hesapla
  double get freeShippingProgress {
    if (subtotal >= AppConstants.freeShippingThreshold) return 1.0;
    return subtotal / AppConstants.freeShippingThreshold;
  }
}

extension OrderItemCopyWith on OrderItem {
  OrderItem copyWith({
    String? productId,
    String? productName,
    String? size,
    String? paperType,
    double? price,
    int? quantity,
    List<String>? imageUrls,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      size: size ?? this.size,
      paperType: paperType ?? this.paperType,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}