import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart'; // For formatting dates

class Orderview extends StatefulWidget {
  final String orderId; // Pass the order ID when navigating to this screen

  const Orderview({super.key, required this.orderId});

  @override
  State<Orderview> createState() => _OrderviewState();
}

class _OrderviewState extends State<Orderview> {
  // Future to fetch order details
  Future<DocumentSnapshot> getOrderDetails() async {
    return await FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderId)
        .get();
  }

  // Future to fetch product details by ID
  Future<Map<String, dynamic>> fetchProductById(String productId) async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('Products')
        .doc(productId)
        .get();
    return productSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

          // Fetch order details from the document snapshot
          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          var productIds = orderData['productIds'] as List<dynamic>;
          var quantities = orderData['quantities'] as Map<String, dynamic>;

          // Cast totalCost to double
          var totalCost = (orderData['totalCost'] as num).toDouble();
          var userId = orderData['userId'];
          var orderTime = (orderData['orderTime'] as Timestamp).toDate(); // Convert Firestore timestamp to DateTime

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${widget.orderId}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('User ID: $userId', style: TextStyle(color: Colors.grey)),
                Text('Order Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(orderTime)}', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                const Text('Products:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: productIds.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      String productId = productIds[index];
                      int quantity = quantities[productId];

                      // Use FutureBuilder to fetch the product name
                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchProductById(productId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading product...'),
                            );
                          }

                          if (!productSnapshot.hasData ||
                              productSnapshot.data == null) {
                            return const ListTile(
                              title: Text('Product not found'),
                            );
                          }

                          var productData = productSnapshot.data!;
                          String productName = productData['name'];
                          String productSupplier = productData['user_id'];
                          return ListTile(
                            title: Text(productName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity: $quantity',
                                    style: const TextStyle(color: Colors.grey)),
                                Text('Supplier: $productSupplier',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text('Total Cost: Rs.${totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    printBill();
                  },
                  child: const Text(
                    'Print Bill',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Method to handle the "Print Bill" action
  void printBill() {
    print('Bill is being printed...');
  }
}
