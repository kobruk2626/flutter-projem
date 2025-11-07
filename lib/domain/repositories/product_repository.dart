import 'package:photo_momento/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({
    String? category,
    bool? inStockOnly,
    bool? activeOnly,
  });

  Future<ProductModel> getProduct(String productId);
  Future<List<ProductModel>> getFeaturedProducts();
  Future<void> updateProductStock(String productId, int newStock);
  Stream<List<ProductModel>> streamProducts();
  Future<List<ProductModel>> searchProducts(String query);
}