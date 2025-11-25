import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products (HTTP ${response.statusCode})');
    }
  }
  Future<bool> deleteProduct(int productId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/products/$productId');

    try {
      final res = await http.delete(url);

      if (res.statusCode == 200) {
        print("Product $productId deleted.");
        return true;
      } else {
        print("Failed to delete product: ${res.statusCode} ${res.body}");
        return false;
      }
    } catch (e) {
      print("ERROR deleting product: $e");
      return false;
    }
  }
}
