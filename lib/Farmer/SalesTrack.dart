import 'package:agrix/Farmer/OrderDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class Salestrack extends StatefulWidget {
  const Salestrack({super.key});

  @override
  State<Salestrack> createState() => _SalestrackState();
}

class _SalestrackState extends State<Salestrack> {
  List<String> farmerProductIds = [];
  List<Map<String, dynamic>> farmerOrders = [];

  @override
  void initState() {
    super.initState();
    fetchFarmerProductsAndOrders();
  }

  Future<void> fetchFarmerProductsAndOrders() async {
    try {
      String farmerUserId = FirebaseAuth.instance.currentUser!.uid;
      print('Fetching products for Farmer ID: $farmerUserId');

      // Fetch farmer's products
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('user_id', isEqualTo: farmerUserId)
          .get();

      if (productSnapshot.docs.isEmpty) {
        print("No products found for this farmer.");
      } else {
        print("Products fetched successfully!");
      }

      setState(() {
        farmerProductIds = productSnapshot.docs.map((doc) {
          return doc.id;
        }).toList();
      });

      print("Farmer Product IDs: $farmerProductIds");

      // Fetch orders that have these products
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('productIds', arrayContainsAny: farmerProductIds)
          .get();

      print("Total Orders Fetched: ${orderSnapshot.docs.length}");

      for (var orderDoc in orderSnapshot.docs) {
        Map<String, dynamic>? orderData = orderDoc.data() as Map<String, dynamic>?;

        if (orderData != null) {
          List<dynamic>? productIdsInOrder = orderData['productIds'] as List<dynamic>?;
          Map<String, dynamic>? quantitiesInOrder = orderData['quantities'] as Map<String, dynamic>?;

          // Fetch userId from the order
          String userId = orderData['userId'] ?? 'Unknown User'; // Fetch userId

          if (productIdsInOrder != null && quantitiesInOrder != null) {
            bool hasFarmerProduct = productIdsInOrder.any((productId) {
              return farmerProductIds.contains(productId);
            });

            if (hasFarmerProduct) {
              List<Map<String, dynamic>> farmerProductsInOrder = [];
              double totalCostForFarmer = 0.0;

              for (var productId in productIdsInOrder) {
                if (farmerProductIds.contains(productId)) {
                  int quantity = quantitiesInOrder[productId] ?? 0;

                  // Fetch price from the Products collection if not available in the order
                  double productPrice = 0.0;
                  DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
                      .collection('Products')
                      .doc(productId)
                      .get();

                  if (productSnapshot.exists) {
                    var priceData = productSnapshot['price'];
                    if (priceData is String) {
                      productPrice = double.parse(priceData); // Convert string to double
                    } else if (priceData is num) {
                      productPrice = priceData.toDouble(); // Handle number types (int, double)
                    }
                  }

                  totalCostForFarmer += quantity * productPrice;

                  farmerProductsInOrder.add({
                    'productId': productId,
                    'quantity': quantity,
                    'price': productPrice,
                  });
                }
              }

              // Format timestamp to readable date and time
              Timestamp? orderTimestamp = orderData['orderTime'] as Timestamp?;
              String formattedDateTime = 'Unknown Date';
              if (orderTimestamp != null) {
                DateTime orderDateTime = orderTimestamp.toDate();
                formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(orderDateTime);
              }

              setState(() {
                farmerOrders.add({
                  'orderId': orderDoc.id,
                  'userId': userId, // Store userId from orders
                  'totalCost': totalCostForFarmer, // Update total cost for farmer's products only
                  'orderTime': formattedDateTime, // Use formatted date and time
                  'products': farmerProductsInOrder,
                });
              });
            }
          }
        }
      }

      if (farmerOrders.isEmpty) {
        print("No orders found for farmer's products.");
      }

    } catch (e) {
      print("Error fetching farmer products or orders: $e");
    }
  }

  void navigateToOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Orderdetails(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Sales Track',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: farmerOrders.isEmpty
          ? Center(child: SpinKitWaveSpinner(color: Colors.green))
          : ListView.builder(
        itemCount: farmerOrders.length,
        itemBuilder: (context, index) {
          var order = farmerOrders[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListTile(
              title: Text(
                "Order ID: ${order['orderId']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User ID: ${order['userId']}"), // Display userId from orders
                  Text("Total Cost: ${order['totalCost']}"),
                  Text("Order Time: ${order['orderTime']}"),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                navigateToOrderDetails(order);
              },
            ),
          );
        },
      ),
    );
  }
}
