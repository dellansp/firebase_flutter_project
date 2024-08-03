import 'package:firebase_flutter_project/bloc/product/model/product_model.dart';
import 'package:flutter/material.dart';
import '../services/product_service.dart'; // Sesuaikan path sesuai struktur project Anda


class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  String _category = 'All';

  List<Product> get products => _products;
  String get category => _category;

  void setCategory(String category) {
    _category = category;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      if (_category == 'All') {
        _products = await _productService.fetchAllProducts();
      } else {
        _products = await _productService.fetchProductsByCategory(_category);
      }
      notifyListeners();
    } catch (e) {
      // Handle error
      print(e);
    }
  }
}
