import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../OrderView.dart';

class Pastorders extends StatefulWidget {
  const Pastorders({super.key});

  @override
  State<Pastorders> createState() => _PastordersState();
}

class _PastordersState extends State<Pastorders> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchAllOrders();
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      // Fetch all documents from the 'Orders' collection
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Process each order to fetch and sum quantities
      List<Map<String, dynamic>> orders = [];
      for (var doc in orderSnapshot.docs) {
        // Fetch the products sub-collection for each order
        QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
            .collection('Orders')
            .doc(doc.id)
            .collection('products')
            .get();

        // Sum up quantities
        int totalQuantity = productsSnapshot.docs.fold(
          0,
              (sum, productDoc) {
            var data = productDoc.data() as Map<String, dynamic>;
            // Access quantity from nested map
            var quantitiesMap = data['quantities'] as Map<String, dynamic>?; // Adjust key name if needed
            int quantity = (quantitiesMap?['quantity'] as int?) ?? 0; // Default to 0 if not present
            return sum + quantity;
          },
        );

        // Add order data with total quantity
        var orderData = doc.data() as Map<String, dynamic>;
        orderData['orderId'] = doc.id;
        orderData['totalQuantity'] = totalQuantity;
        orders.add(orderData);
      }

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Past Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SpinKitWaveSpinner(color: Colors.green));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              String orderId = order['orderId'] ?? 'Unknown';
              double totalCost = (order['totalCost'] as num?)?.toDouble() ?? 0.0; // Safely cast totalCost
              int totalQuantity = order['totalQuantity'] ?? 0;
              Timestamp timestamp = order['orderTime'] as Timestamp? ?? Timestamp.now();
              DateTime orderDate = timestamp.toDate();

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order ID: $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Quantity: $totalQuantity'),
                      Text('Total Cost: Rs. ${totalCost.toStringAsFixed(2)}'),
                      Text('Order Date: ${orderDate.toLocal()}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Orderview(orderId: orderId)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
