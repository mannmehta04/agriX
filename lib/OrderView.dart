import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Orderview extends StatefulWidget {
  final String orderId;

  const Orderview({super.key, required this.orderId});

  @override
  State<Orderview> createState() => _OrderviewState();
}

class _OrderviewState extends State<Orderview> {
  Future<DocumentSnapshot> getOrderDetails() async {
    return await FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderId)
        .get();
  }

  Future<Map<String, dynamic>> fetchProductById(String productId) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('Products')
        .doc(productId)
        .get();
    return productSnapshot.data() as Map<String, dynamic>;
  }

  Future<String> fetchUserFullName(String userId) async {
    DocumentSnapshot farmerSnapshot = await FirebaseFirestore.instance
        .collection('Farmers')
        .doc(userId)
        .get();

    if (farmerSnapshot.exists) {
      Map<String, dynamic> farmerData = farmerSnapshot.data() as Map<String, dynamic>;
      String firstName = farmerData['firstName'] ?? 'Unknown';
      String lastName = farmerData['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    } else {
      DocumentSnapshot consumerSnapshot = await FirebaseFirestore.instance
          .collection('Consumers')
          .doc(userId)
          .get();

      if (consumerSnapshot.exists) {
        Map<String, dynamic> consumerData = consumerSnapshot.data() as Map<String, dynamic>;
        String firstName = consumerData['firstName'] ?? 'Unknown';
        String lastName = consumerData['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        return 'Unknown';
      }
    }
  }

  Future<String> fetchFarmerFullName(String farmerId) async {
    DocumentSnapshot farmerSnapshot = await FirebaseFirestore.instance
        .collection('Farmers')
        .doc(farmerId)
        .get();

    if (farmerSnapshot.exists) {
      Map<String, dynamic> farmerData = farmerSnapshot.data() as Map<String, dynamic>;
      String firstName = farmerData['firstName'] ?? 'Unknown';
      String lastName = farmerData['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    } else {
      return 'Unknown Farmer';
    }
  }

  Future<Uint8List> generateInvoice(String orderId, String userFullName, List<dynamic> productIds, Map<String, dynamic> quantities, double totalCost, DateTime orderTime) async {
    final pdf = pw.Document();
    final billDateTime = DateTime.now();
    final baseColor = PdfColors.green;
    final accentColor = PdfColors.grey800;

    // Prepare the product rows
    List<pw.TableRow> productRows = [];

    productRows.add(pw.TableRow(children: [
      pw.Container(
        width: 100, // Set the desired width
        padding: const pw.EdgeInsets.all(8.0),
        color: baseColor,
        child: pw.Center(child: pw.Text('Product Name (ID)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), maxLines: 1)),
      ),
      pw.Container(
        width: 100, // Set the desired width
        padding: const pw.EdgeInsets.all(8.0),
        color: baseColor,
        child: pw.Center(child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), maxLines: 1)),
      ),
      pw.Container(
        width: 100, // Set the desired width
        padding: const pw.EdgeInsets.all(8.0),
        color: baseColor,
        child: pw.Center(child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), maxLines: 1)),
      ),
      pw.Container(
        width: 100, // Set the desired width
        padding: const pw.EdgeInsets.all(8.0),
        color: baseColor,
        child: pw.Center(child: pw.Text('Supplier Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), maxLines: 1)),
      ),
    ]));

    // Fetch product details
    for (String productId in productIds) {
      int quantity = quantities[productId];
      var productData = await fetchProductById(productId);
      String productName = productData['name'];
      String supplierId = productData['user_id'];
      String supplierName = await fetchFarmerFullName(supplierId);

      // Safely parse price
      double price = double.tryParse(productData['price'].toString()) ?? 0.0;
      double totalPrice = price * quantity;

      // Format product name with ID
      String formattedProductName = '$productName ($productId)';

      productRows.add(pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(formattedProductName, style: pw.TextStyle(fontSize: 14)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text('$quantity', style: pw.TextStyle(fontSize: 14)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text('Rs. ${totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(supplierName, style: pw.TextStyle(fontSize: 14)),
        ),
      ]));
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Header(
                    level: 0,
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('AgriX', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: baseColor)),
                    ),
                  ),
                  pw.Divider(color: baseColor, thickness: 1.5),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Invoice', style: pw.TextStyle(fontSize: 20, color: accentColor)),
                      pw.Text('Order ID: $orderId', style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Customer: $userFullName', style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                  pw.Text('Order Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(orderTime)}', style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                  pw.Text('Bill Generated: ${DateFormat('dd-MM-yyyy hh:mm a').format(billDateTime)}', style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                  pw.SizedBox(height: 20),
                  pw.Text('Products:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: baseColor)),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
                    columnWidths: {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(2),
                      2: pw.FlexColumnWidth(2),
                      3: pw.FlexColumnWidth(3),
                    },
                    children: productRows,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Total Cost: Rs.${totalCost.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(color: baseColor),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 16, color: accentColor, fontStyle: pw.FontStyle.italic)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(translate('Order Details'),
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SpinKitWaveSpinner(color: Colors.green));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No order details found.'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          var productIds = orderData['productIds'] as List<dynamic>;
          var quantities = orderData['quantities'] as Map<String, dynamic>;
          var totalCost = (orderData['totalCost'] as num).toDouble();
          var userId = orderData['userId'];
          var orderTime = (orderData['orderTime'] as Timestamp).toDate();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${translate('Order Id')}: ${widget.orderId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: fetchUserFullName(userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading user...');
                    }
                    if (!userSnapshot.hasData || userSnapshot.data == null) {
                      return const Text('User not found', style: TextStyle(color: Colors.grey));
                    }
                    return Text('${translate('Customer')}: ${userSnapshot.data}', style: TextStyle(color: Colors.grey));
                  },
                ),
                Text('${translate('Order Time')}: ${DateFormat('dd-MM-yyyy hh:mm a').format(orderTime)}', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                Text('${translate('Products')}:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: productIds.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      String productId = productIds[index];
                      int quantity = quantities[productId];

                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchProductById(productId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading product...'));
                          }

                          if (!productSnapshot.hasData || productSnapshot.data == null) {
                            return const ListTile(title: Text('Product not found'));
                          }

                          var productData = productSnapshot.data!;
                          String productName = translate(productData['name']);
                          String supplierId = productData['user_id'];

                          return FutureBuilder<String>(
                            future: fetchFarmerFullName(supplierId),
                            builder: (context, farmerSnapshot) {
                              if (farmerSnapshot.connectionState == ConnectionState.waiting) {
                                return ListTile(
                                  title: Text(productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Loading supplier...', style: TextStyle(color: Colors.grey)),
                                );
                              }
                              if (!farmerSnapshot.hasData || farmerSnapshot.data == null) {
                                return ListTile(
                                  title: Text(translate(productName), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  subtitle: const Text('Supplier not found', style: TextStyle(color: Colors.grey)),
                                );
                              }
                              String farmerFullName = farmerSnapshot.data!;
                              return ListTile(
                                title: Text(productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${translate('Quantity')}: $quantity', style: const TextStyle(color: Colors.grey)),
                                    Text('${translate('Supplier')}: $farmerFullName', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text('${translate('Total Cost')}: ₹ ${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    printBill();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(translate('Print Bill'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void printBill() async {
    var orderData = await getOrderDetails();
    var userFullName = await fetchUserFullName(orderData['userId']);
    var productIds = orderData['productIds'];
    var quantities = orderData['quantities'];
    var totalCost = (orderData['totalCost'] as num).toDouble();
    var orderTime = (orderData['orderTime'] as Timestamp).toDate();

    final pdfData = await generateInvoice(
      widget.orderId,
      userFullName,
      productIds,
      quantities,
      totalCost,
      orderTime,
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }
}
