import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'SucessPage.dart';

class Ordersummary extends StatefulWidget {
  final Map<String, int> productQuantities; // A map of product IDs and their quantities
  final double totalCost;
  final int totalQuantity;

  const Ordersummary({
    super.key,
    required this.productQuantities,
    required this.totalCost,
    required this.totalQuantity,
  });

  @override
  State<Ordersummary> createState() => _OrdersummaryState();
}

class _OrdersummaryState extends State<Ordersummary> {
  Future<List<Map<String, dynamic>>> _fetchProductDetails() async {
    List<Map<String, dynamic>> products = [];

    // Loop through productIds and fetch details from Firestore
    for (String productId in widget.productQuantities.keys) {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Products') // Assuming products are stored in 'Products' collection
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

        // Ensure the price is treated as a double
        double price = 0.0;
        if (productData['price'] is String) {
          price = double.tryParse(productData['price']) ?? 0.0; // Convert string to double
        } else if (productData['price'] is double) {
          price = productData['price']; // It's already a double
        }

        productData['price'] = price; // Store the converted price back into the product data
        productData['quantity'] = widget.productQuantities[productId]; // Attach the quantity from the cart
        products.add(productData);
      }
    }
    return products;
  }
  Future<void> uploadOrderData({
    required List<String> productIds,
    required String userId,
    required Map<String, int> quantities, // Map of product IDs and their quantities
    required double totalCost,
  }) async {
    try {
      // Prepare the order data
      Map<String, dynamic> orderData = {
        'userId': userId,
        'productIds': productIds,
        'quantities': quantities, // Store the quantities for each product
        'totalCost': totalCost,
        'orderTime': Timestamp.now(), // Store the current time
      };

      // Upload the data to Firestore (e.g., to an "Orders" collection)
      await FirebaseFirestore.instance.collection('Orders').add(orderData);

      print('Order uploaded successfully!');
      await _updateProductQuantities(quantities);

    } catch (e) {
      print('Failed to upload order: $e');
    }
  }

  Future<void> clearUserCart(String userId) async {
    try {
      // Reference to the user's 'products' sub-collection in the Cart document
      CollectionReference cartProductsRef = FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId) // The cart document ID is the user ID
          .collection('products');

      // Fetch all documents (products) in the user's cart
      QuerySnapshot cartSnapshot = await cartProductsRef.get();

      // If there are no products, just return
      if (cartSnapshot.docs.isEmpty) {
        print('Cart is already empty.');
        return;
      }

      // Use a batch to delete all documents in one atomic operation
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        // Add each document delete operation to the batch
        batch.delete(doc.reference);
      }

      // Commit the batch operation to delete all documents
      await batch.commit();
      print('Cart cleared successfully!');
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Future<void> _updateProductQuantities(Map<String, int> quantities) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String productId in quantities.keys) {
      DocumentReference productRef = FirebaseFirestore.instance.collection('Products').doc(productId);

      // Fetch current product data
      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

        // Get current quantity from the product data and convert it from string to int
        int? currentQuantity = 0;
        if (productData['quantity'] is String) {
          currentQuantity = int.tryParse(productData['quantity']) ; // Convert string to int
        } else if (productData['quantity'] is int) {
          currentQuantity = productData['quantity']; // It's already an int
        }

        // Calculate new quantity
        int newQuantity = currentQuantity! - quantities[productId]!;

        // Ensure quantity doesn't drop below zero
        if (newQuantity < 0) newQuantity = 0;

        // Update the product quantity as a string in Firestore
        batch.update(productRef, {'quantity': newQuantity.toString()});
      }
    }

    // Commit the batch update
    await batch.commit();
    print('Product quantities updated successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text("Order Summary",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWaveSpinner(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading order details'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No product details available'));
          }

          List<Map<String, dynamic>> productDetails = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: productDetails.length,
                    itemBuilder: (context, index) {
                      var product = productDetails[index];
                      int quantity = product['quantity']; // Quantity from cart
                      double totalPrice = product['price'] * quantity;

                      return ListTile(
                        leading: Image.network(
                          product['img1Url'] ?? 'default_image_url',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(product['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: Rs.${product['price'].toStringAsFixed(2)}'),
                            Text('Quantity: $quantity'),
                            Text('Total: Rs.${totalPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                // Display total quantity and total cost
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Quantity: ${widget.totalQuantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Total Cost: Rs.${widget.totalCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Confirm Order button
                Center(
                  child: ElevatedButton(
                    onPressed: () async{
                      String userId = FirebaseAuth.instance.currentUser!.uid;

                      // Get product IDs, quantities, and total cost from the current order
                      Map<String, int> productQuantities = widget.productQuantities;
                      List<String> productIds = productQuantities.keys.toList();
                      double totalCost = widget.totalCost;

                      // Upload the order to Firestore
                      await uploadOrderData(
                        productIds: productIds,
                        userId: userId,
                        quantities: productQuantities,
                        totalCost: totalCost,
                      );

                      await clearUserCart(userId);

                      // Navigate to another page or show a success message
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SuccessPage()));
                    },
                    child: Text('Confirm Order'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
}
