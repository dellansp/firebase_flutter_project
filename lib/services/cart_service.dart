import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addToCart(String productId) async {
    CollectionReference cart = FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');
    DocumentSnapshot snapshot = await cart.doc(productId).get();

    if (snapshot.exists) {
      cart.doc(productId).update({
        'quantity': snapshot['quantity'] + 1,
      });
    } else {
      cart.doc(productId).set({
        'productId': productId,
        'quantity': 1,
      });
    }
  }

  Future<void> removeFromCart(String productId) async {
    CollectionReference cart = FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');
    DocumentSnapshot snapshot = await cart.doc(productId).get();

    if (snapshot.exists) {
      if (snapshot['quantity'] > 1) {
        cart.doc(productId).update({
          'quantity': snapshot['quantity'] - 1,
        });
      } else {
        cart.doc(productId).delete();
      }
    }
  }

  Future<void> updateCart(String productId, int quantity) async {
    CollectionReference cart = FirebaseFirestore.instance.collection('users').doc(uid).collection('cart');

    if (quantity > 0) {
      cart.doc(productId).update({
        'quantity': quantity,
      });
    } else {
      cart.doc(productId).delete();
    }
  }
}
