import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_project/pages/login_page.dart';
import 'package:firebase_flutter_project/pages/product_page.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Handle Auth
  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const ProductScreen(); // Redirect to product screen if logged in
        } else {
          return const LoginScreen(); // Redirect to login screen if not logged in
        }
      },
    );
  }

  // Sign Out
  signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Sign In
  signIn(String email, String password) {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  // Register
  signUp(String name, String email, String password, String phone) {
    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)
        .then((result) {
      FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
      });
    });
  }
}
