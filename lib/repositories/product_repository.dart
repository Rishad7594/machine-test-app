import '../services/api_service.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiService _api = ApiService();

  Future<List<Product>> getProducts() => _api.fetchProducts();
}