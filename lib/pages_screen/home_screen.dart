import 'package:firebase_flutter_project/bloc/product/provider/product_provider.dart';
import 'package:firebase_flutter_project/pages_screen/order_pages.dart';
import 'package:firebase_flutter_project/pages_screen/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> _pages = [
    ProductListPage(),
    OrderPage(),
    ProfilePage(), // Halaman profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          DropdownButton<String>(
            value: context.watch<ProductProvider>().category,
            onChanged: (value) {
              if (value != null) {
                context.read<ProductProvider>().setCategory(value);
              }
            },
            items: <String>['All', 'electronics', 'jewelery', 'men\'s clothing', 'women\'s clothing']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.products.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return ListTile(
              leading: Image.network(product.imageUrl, width: 50, height: 50),
              title: Text(product.title),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                );
              },
            );
          },
        );
      },
    );
  }
}
