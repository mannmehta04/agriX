import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../OrderView.dart';

class Pastorders extends StatefulWidget {
  const Pastorders({super.key});

  @override
  State<Pastorders> createState() => _PastordersState();
}

class _PastordersState extends State<Pastorders> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  String _sortBy = 'date'; // Default sort option
  bool _isAscending = true; // Default order is ascending

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchAllOrders();
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      List<Map<String, dynamic>> orders = [];
      for (var doc in orderSnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;

        Map<String, dynamic> quantitiesMap = orderData['quantities'] ?? {};

        int totalQuantity = quantitiesMap.values.fold(0, (sum, item) {
          return sum + (item as int);
        });

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

  List<Map<String, dynamic>> _sortOrders(List<Map<String, dynamic>> orders) {
    orders.sort((a, b) {
      int compareResult = 0;
      switch (_sortBy) {
        case 'date':
          Timestamp aTime = a['orderTime'] as Timestamp? ?? Timestamp.now();
          Timestamp bTime = b['orderTime'] as Timestamp? ?? Timestamp.now();
          compareResult = aTime.compareTo(bTime);
          break;
        case 'price':
          double aCost = (a['totalCost'] as num?)?.toDouble() ?? 0.0;
          double bCost = (b['totalCost'] as num?)?.toDouble() ?? 0.0;
          compareResult = aCost.compareTo(bCost);
          break;
        case 'quantity':
          int aQuantity = a['totalQuantity'] ?? 0;
          int bQuantity = b['totalQuantity'] ?? 0;
          compareResult = aQuantity.compareTo(bQuantity);
          break;
      }
      return _isAscending ? compareResult : -compareResult;
    });
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(translate('Past Orders'), style: TextStyle(fontWeight: FontWeight.bold)),
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

          List<Map<String, dynamic>> orders = _sortOrders(snapshot.data!);

          return Stack(
            children: [
              ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  String orderId = order['orderId'] ?? 'Unknown';
                  double totalCost = (order['totalCost'] as num?)?.toDouble() ?? 0.0;
                  int totalQuantity = order['totalQuantity'] ?? 0;
                  Timestamp timestamp = order['orderTime'] as Timestamp? ?? Timestamp.now();
                  DateTime orderDate = timestamp.toDate();

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('${translate('Order Id')}: $orderId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${translate('Total Quantity')}: $totalQuantity'),
                          Text('${translate('Total Cost')}: ₹ ${totalCost.toStringAsFixed(2)}'),
                          Text('${translate('Order Date')}: ${orderDate.toLocal()}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Orderview(orderId: orderId)),
                        );
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
                                'Filter Options',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.calendar_today, color: Colors.green),
                                title: const Text('Filter by Date'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'date';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.attach_money, color: Colors.green),
                                title: const Text('Filter by Price'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'price';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.shopping_cart, color: Colors.green),
                                title: const Text('Filter by Quantity'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'quantity';
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
          );
        },
      ),
    );
  }
}
