import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  User? user;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  String? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadCartItems();
    }
  }

  Future<void> _loadCartItems() async {
    if (user != null) {
      DocumentSnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .get();
      if (cartSnapshot.exists) {
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        setState(() {
          cartItems = (cartData['items'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
          totalAmount = cartItems.fold<double>(
            0.0,
            (sum, item) {
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              final quantity = item['quantity'] as int? ?? 0;
              return sum + (price * quantity);
            },
          );
        });
      }
    }
  }

  Future<String> _generateAndSaveReceipt() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('HAPPY SHOP',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Jl. Contoh No. 123, Jakarta',
              style: pw.TextStyle(fontSize: 14)),
          pw.Text('Telp: 0812-3456-7890', style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Creator: Della Novita S P',
              style: pw.TextStyle(fontSize: 14)),
          pw.Text('Tanggal: $date', style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Detail Belanja:',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ...cartItems
              .map((item) => pw.Text(
                  '${item['title']} - ${item['quantity']} x \$${item['price']} = \$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 14)))
              .toList(),
          pw.SizedBox(height: 10),
          pw.Text('Total: \$${totalAmount.toStringAsFixed(2)}',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(
              'Metode Pembayaran: ${selectedPaymentMethod ?? 'Not Selected'}',
              style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Terima kasih atas pembelian Anda!',
              style:
                  pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    ));

    final output = await getTemporaryDirectory();
    final file =
        File("${output.path}/receipt_${now.millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  Future<void> _saveReceiptAndCreateFirestoreEntry() async {
    final receiptPath = await _generateAndSaveReceipt();

    // Save data to Firestore
    final checkoutRef = FirebaseFirestore.instance.collection('checkout').doc();
    await checkoutRef.set({
      'Tanggal': DateTime.now().toIso8601String(),
      'items': cartItems
          .map((item) => {
                'title': item['title'],
                'quantity': item['quantity'],
                'price': item['price'],
              })
          .toList(),
      'total': totalAmount,
      'metodePembayaran': selectedPaymentMethod,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Struk berhasil disimpan di $receiptPath dan data checkout diperbarui di Firestore.')),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Struk Belanja'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HAPPY SHOP',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Jl. Contoh No. 123, Jakarta',
                    style: TextStyle(fontSize: 14)),
                Text('Telp: 0812-3456-7890', style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Text('Creator: Della Novita S P',
                    style: TextStyle(fontSize: 14)),
                Text(
                    'Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Text('Detail Belanja:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...cartItems
                    .map((item) => Text(
                        '${item['title']} - ${item['quantity']} x \$${item['price']} = \$${(item['quantity'] * item['price']).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14)))
                    .toList(),
                SizedBox(height: 10),
                Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                    'Metode Pembayaran: ${selectedPaymentMethod ?? 'Not Selected'}',
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 10),
                Text('Terima kasih atas pembelian Anda!',
                    style:
                        TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _saveReceiptAndCreateFirestoreEntry();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green[800],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Keranjang Anda kosong.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftar Produk',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          title: Text(item['title']),
                          subtitle: Text(
                              'Qty: ${item['quantity']} - \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Metode Pembayaran', style: TextStyle(fontSize: 18)),
                  ListTile(
                    title: Text('E-Wallet'),
                    leading: Radio<String>(
                      value: 'e_wallet',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                    subtitle: Row(
                      children: [
                        Image.asset('assets/images/gopay.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/shopeepay.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/ovo.png', width: 50),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Bank Lokal'),
                    leading: Radio<String>(
                      value: 'bank_local',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                    subtitle: Row(
                      children: [
                        Image.asset('assets/images/bri.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/mandiri.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/bca.png', width: 50),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Kartu Kredit'),
                    leading: Radio<String>(
                      value: 'credit_card',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                    ),
                    subtitle: Row(
                      children: [
                        Image.asset('assets/images/paypal.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/visa.png', width: 50),
                        SizedBox(width: 10),
                        Image.asset('assets/images/mastercard.png', width: 50),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedPaymentMethod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Silakan pilih metode pembayaran.'),
                          ),
                        );
                        return;
                      }
                      _showCheckoutDialog(context);
                    },
                    child: Text('Konfirmasi Pembelian'),
                  ),
                ],
              ),
            ),
    );
  }
}
