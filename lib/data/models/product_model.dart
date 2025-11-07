import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final String size;
  final String paperType;
  final double price;
  final int stock;
  final int minStock;
  final bool isActive;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final int totalSales;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.paperType,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.isActive,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    this.totalSales = 0,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      size: data['size'] ?? '',
      paperType: data['paperType'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      minStock: data['minStock'] ?? 0,
      isActive: data['isActive'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalSales: data['totalSales'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'size': size,
      'paperType': paperType,
      'price': price,
      'stock': stock,
      'minStock': minStock,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalSales': totalSales,
    };
  }

  // CopyWith metodu
  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? size,
    String? paperType,
    double? price,
    int? stock,
    int? minStock,
    bool? isActive,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    int? totalSales,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      size: size ?? this.size,
      paperType: paperType ?? this.paperType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      totalSales: totalSales ?? this.totalSales,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(2)}₺';

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;

  // Stok durumu metni
  String get stockStatus {
    if (isOutOfStock) return 'Stokta Yok';
    if (isLowStock) return 'Az Stok';
    return 'Stokta Var';
  }

  // Stok durumu rengi için yardımcı metod
  String get stockStatusColor {
    if (isOutOfStock) return 'red';
    if (isLowStock) return 'orange';
    return 'green';
  }
}