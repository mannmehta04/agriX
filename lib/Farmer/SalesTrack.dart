import 'package:agrix/Farmer/OrderDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .get();

      print("Total Orders Fetched: ${orderSnapshot.docs.length}");

      for (var orderDoc in orderSnapshot.docs) {
        Map<String, dynamic>? orderData = orderDoc.data() as Map<String, dynamic>?;

        if (orderData != null) {
          List<dynamic> productIdsInOrder = orderData['productIds'];
          Map<String, dynamic> quantitiesInOrder = orderData['quantities'];

          bool hasFarmerProduct = productIdsInOrder.any((productId) {
            return farmerProductIds.contains(productId);
          });

          if (hasFarmerProduct) {
            List<Map<String, dynamic>> farmerProductsInOrder = [];

            productIdsInOrder.forEach((productId) {
              if (farmerProductIds.contains(productId)) {
                farmerProductsInOrder.add({
                  'productId': productId,
                  'quantity': quantitiesInOrder[productId] ?? 0,
                });
              }
            });

            setState(() {
              farmerOrders.add({
                'orderId': orderDoc.id,
                'totalCost': orderData['totalCost'],
                'orderTime': orderData['orderTime'],
                'products': farmerProductsInOrder,
              });
            });
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
        title: Text(
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
