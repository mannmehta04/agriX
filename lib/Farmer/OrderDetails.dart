import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Orderdetails extends StatefulWidget {
  final Map<String, dynamic> order; // Receives the order data

  const Orderdetails({super.key, required this.order});

  @override
  State<Orderdetails> createState() => _OrderdetailsState();
}

class _OrderdetailsState extends State<Orderdetails> {
  String? firstName; // To store the firstName after fetching
  String? lastName;  // To store the lastName after fetching

  @override
  void initState() {
    super.initState();
    fetchUserDetails(widget.order['userId']);
  }

  Future<void> fetchUserDetails(String userId) async {
    try {
      // Check if the userId exists in Farmers collection
      DocumentSnapshot farmerSnapshot =
      await FirebaseFirestore.instance.collection('Farmers').doc(userId).get();

      if (farmerSnapshot.exists) {
        setState(() {
          firstName = farmerSnapshot['firstName'];
          lastName = farmerSnapshot['lastName']; // Fetch lastName from Farmers
        });
      } else {
        // If not found in Farmers, check in Consumers collection
        DocumentSnapshot consumerSnapshot =
        await FirebaseFirestore.instance.collection('Consumers').doc(userId).get();

        if (consumerSnapshot.exists) {
          setState(() {
            firstName = consumerSnapshot['firstName'];
            lastName = consumerSnapshot['lastName']; // Fetch lastName from Consumers
          });
        } else {
          setState(() {
            firstName = 'Unknown'; // Handle case if userId not found in both
            lastName = ''; // Handle lastName for unknown user
          });
        }
      }
    } catch (e) {
      setState(() {
        firstName = 'Error fetching name';
        lastName = ''; // Handle lastName error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(translate('Order Details')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${translate('Order Id')}: ${order['orderId']}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text("${translate('Total Cost')}: ${order['totalCost']}"),
                Text("${translate('Order Time')}: ${order['orderTime']}"),
                Divider(),
                Text(
                  "${translate('Ordered By')}: ${firstName ?? 'Loading...'} ${lastName ?? ''}", // Display firstName and lastName
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Divider(),
                Text(
                  translate("Products Sold"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ...order['products'].map<Widget>((product) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${translate('Product Id')}: ${product['productId']}, ${translate('Quantity')}: ${product['quantity']}",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
