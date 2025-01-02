import 'package:agrix/Farmer/OrderDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';

class Salestrack extends StatefulWidget {
  const Salestrack({super.key});

  @override
  State<Salestrack> createState() => _SalestrackState();
}

class _SalestrackState extends State<Salestrack> {
  List<String> farmerProductIds = [];
  List<Map<String, dynamic>> farmerOrders = [];
  String _sortBy = 'date'; // Default sort option
  bool _isAscending = true; // Default order is ascending

  @override
  void initState() {
    super.initState();
    fetchFarmerProductsAndOrders();
  }

  Future<void> fetchFarmerProductsAndOrders() async {
    try {
      String farmerUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch farmer's products
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('user_id', isEqualTo: farmerUserId)
          .get();

      setState(() {
        farmerProductIds = productSnapshot.docs.map((doc) => doc.id).toList();
      });

      // Fetch orders that have these products
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('productIds', arrayContainsAny: farmerProductIds)
          .get();

      for (var orderDoc in orderSnapshot.docs) {
        Map<String, dynamic>? orderData = orderDoc.data() as Map<String, dynamic>?;

        if (orderData != null) {
          List<dynamic>? productIdsInOrder = orderData['productIds'] as List<dynamic>?;
          Map<String, dynamic>? quantitiesInOrder = orderData['quantities'] as Map<String, dynamic>?;

          String userId = orderData['userId'] ?? 'Unknown User';

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

                  double productPrice = 0.0;
                  DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
                      .collection('Products')
                      .doc(productId)
                      .get();

                  if (productSnapshot.exists) {
                    var priceData = productSnapshot['price'];
                    if (priceData is String) {
                      productPrice = double.parse(priceData);
                    } else if (priceData is num) {
                      productPrice = priceData.toDouble();
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

              Timestamp? orderTimestamp = orderData['orderTime'] as Timestamp?;
              String formattedDateTime = 'Unknown Date';
              if (orderTimestamp != null) {
                DateTime orderDateTime = orderTimestamp.toDate();
                formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(orderDateTime);
              }

              setState(() {
                farmerOrders.add({
                  'orderId': orderDoc.id,
                  'userId': userId,
                  'totalCost': totalCostForFarmer,
                  'orderTime': formattedDateTime,
                  'products': farmerProductsInOrder,
                });
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching farmer products or orders: $e");
    }
  }

  List<Map<String, dynamic>> _sortOrders(List<Map<String, dynamic>> orders) {
    orders.sort((a, b) {
      int compareResult = 0;
      switch (_sortBy) {
        case 'date':
          compareResult = a['orderTime'].compareTo(b['orderTime']);
          break;
        case 'price':
          compareResult = a['totalCost'].compareTo(b['totalCost']);
          break;
        default:
          break;
      }
      return _isAscending ? compareResult : -compareResult;
    });
    return orders;
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
          translate('Sales Track'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          farmerOrders.isEmpty
              ? Center(child: SpinKitWaveSpinner(color: Colors.green))
              : ListView.builder(
            itemCount: farmerOrders.length,
            itemBuilder: (context, index) {
              var order = farmerOrders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                  title: Text(
                    "${translate('Order Id')}: ${order['orderId']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${translate('User Id')}: ${order['userId']}"),
                      Text("${translate('Total Cost')}: ${order['totalCost']}"),
                      Text("${translate('Order Time')}: ${order['orderTime']}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    navigateToOrderDetails(order);
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                  ),
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sort Options',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.calendar_today, color: Colors.green),
                            title: const Text('Sort by Date'),
                            onTap: () {
                              setState(() {
                                _sortBy = 'date';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.attach_money, color: Colors.green),
                            title: const Text('Sort by Price'),
                            onTap: () {
                              setState(() {
                                _sortBy = 'price';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                              color: Colors.green,
                            ),
                            title: Text(
                              _isAscending ? 'Descending Order' : 'Ascending Order',
                            ),
                            onTap: () {
                              setState(() {
                                _isAscending = !_isAscending;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.filter_alt),
            ),
          ),
        ],
      ),
    );
  }
}
