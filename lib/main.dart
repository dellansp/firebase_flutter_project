import 'package:firebase_flutter_project/pages/cart_screen.dart';
import 'package:firebase_flutter_project/pages/checkout_page.dart';
import 'package:firebase_flutter_project/pages/edit_profil_page.dart';
import 'package:firebase_flutter_project/pages/login_page.dart';
import 'package:firebase_flutter_project/pages/main_page.dart';
import 'package:firebase_flutter_project/pages/product_page.dart';
import 'package:firebase_flutter_project/pages/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Application',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          const LoginScreen(), // Mengarah ke halaman login saat aplikasi dimulai
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/products': (context) => const ProductScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutPage(),
        '/profile': (context) => ProfileScreen(),
        '/edit_profile': (context) => EditProfilePage(),
      },
    );
  }
}
