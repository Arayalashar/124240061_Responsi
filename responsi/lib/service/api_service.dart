import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products?limit=30'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk dari API');
    }
  }

  static Future<Product> getSingleProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail produk');
    }
  }

  static Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products/category-list'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Gagal memuat daftar kategori');
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'];
      return products.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk kategori $category');
    }
  }
}
