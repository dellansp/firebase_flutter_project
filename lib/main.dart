import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_project/auth/auth_service.dart';
import 'package:firebase_flutter_project/bloc/product/provider/cart_provider.dart';
import 'package:firebase_flutter_project/bloc/product/provider/product_provider.dart';
import 'package:firebase_flutter_project/pages_screen/home_screen.dart';
import 'package:firebase_flutter_project/pages_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? LoginPage() : HomePage();
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
