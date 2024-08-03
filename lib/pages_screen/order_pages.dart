import 'package:firebase_flutter_project/bloc/product/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'cart_provider.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.cart.length,
                itemBuilder: (context, index) {
                  final product = cartProvider.cart[index];
                  return ListTile(
                    leading:
                        Image.network(product.imageUrl, width: 50, height: 50),
                    title: Text(product.title),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        cartProvider.removeFromCart(product);
                      },
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Total: \$${cartProvider.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cartProvider.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully')));
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
