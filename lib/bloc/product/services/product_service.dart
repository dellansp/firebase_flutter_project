import 'dart:convert';
import 'package:firebase_flutter_project/bloc/product/model/product_model.dart';
import 'package:http/http.dart' as http;


class ProductService {
  final String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/category/$category'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
