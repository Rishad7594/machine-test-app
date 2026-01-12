import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final _base = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$_base/products'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }
}