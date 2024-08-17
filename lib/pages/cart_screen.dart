import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double _totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: Colors.green[800],
        ),
        body: const Center(child: Text('Please log in to view your cart.')),
      );
    }

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = (cartData['items'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();

          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          // Calculate total price
          _totalPrice = items.fold<double>(0.0, (sum, item) {
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final quantity = item['quantity'] as int? ?? 0;
            return sum + (price * quantity);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final productId = item['productId'] as String? ?? 'Unknown';
                    final quantity = item['quantity'] as int? ?? 0;
                    final title = item['title'] as String? ?? 'No title';
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final image = item['image'] as String? ?? '';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: image.isNotEmpty
                            ? Image.network(
                                image,
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 80),
                        title: Text(title),
                        subtitle: Text(
                            'Price: \$${price.toStringAsFixed(2)} x $quantity'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmRemoveFromCart(productId, quantity),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmRemoveFromCart(
      String productId, int currentQuantity) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in to remove items from the cart.')),
      );
      return;
    }

    // final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);

    // Show dialog to select quantity
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int quantityToRemove = 1;

        return AlertDialog(
          title: const Text('Remove Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter quantity to remove:'),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                ),
                onChanged: (value) {
                  quantityToRemove = int.tryParse(value) ?? 1;
                  quantityToRemove = quantityToRemove.clamp(1, currentQuantity);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (quantityToRemove > 0) {
                  await _removeFromCart(productId, quantityToRemove);
                }
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFromCart(String productId, int quantityToRemove) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in to remove items from the cart.')),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(cartRef);
      if (!doc.exists) {
        return;
      }

      final cartData = doc.data() as Map<String, dynamic>;
      final items =
          (cartData['items'] as List<dynamic>).cast<Map<String, dynamic>>();

      final itemIndex =
          items.indexWhere((item) => item['productId'] == productId);
      if (itemIndex >= 0) {
        final item = items[itemIndex];
        final currentQuantity = item['quantity'] as int? ?? 0;

        if (currentQuantity > quantityToRemove) {
          // Update quantity
          items[itemIndex]['quantity'] = currentQuantity - quantityToRemove;
        } else {
          // Remove item from cart
          items.removeAt(itemIndex);
        }

        transaction.update(cartRef, {'items': items});
      }
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed from cart!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove product from cart: $error')),
      );
    });
  }
}
