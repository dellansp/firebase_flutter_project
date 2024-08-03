import 'package:firebase_flutter_project/bloc/product/model/product_model.dart';
import 'package:flutter/material.dart';


class CartProvider with ChangeNotifier {
  final List<Product> _cart = [];

  List<Product> get cart => _cart;

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product);
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    _cart.forEach((product) {
      total += product.price;
    });
    return total;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
