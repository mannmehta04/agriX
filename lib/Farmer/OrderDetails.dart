import 'package:flutter/material.dart';

class Orderdetails extends StatefulWidget {
  final Map<String, dynamic> order; // Receives the order data

  const Orderdetails({super.key, required this.order});

  @override
  State<Orderdetails> createState() => _OrderdetailsState();
}

class _OrderdetailsState extends State<Orderdetails> {
  @override
  Widget build(BuildContext context) {
    // Extracting order details from the passed order data
    var order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
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
                  "Order ID: ${order['orderId']}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text("Total Cost: ${order['totalCost']}"),
                Text("Order Time: ${order['orderTime']}"),
                Divider(),
                Text(
                  "Products Sold:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                // Listing the products sold in the order
                ...order['products'].map<Widget>((product) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "Product ID: ${product['productId']}, Quantity: ${product['quantity']}",
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
