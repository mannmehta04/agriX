import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'SucessPage.dart';

class Ordersummary extends StatefulWidget {
  final Map<String, int> productQuantities;
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
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_qOYfW65K8GRMAg', // Use your Razorpay key_id here
      'amount': (widget.totalCost * 100).toInt(), // Amount in paise
      'name': 'agriX',
      'description': 'Organic Product Payment',
      'timeout': 300, // Payment timeout in seconds

      'prefill': {
        'contact': FirebaseAuth.instance.currentUser!.phoneNumber,
        'email': FirebaseAuth.instance.currentUser!.email,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment success: ${response.paymentId}");
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Map<String, int> productQuantities = widget.productQuantities;
    List<String> productIds = productQuantities.keys.toList();
    double totalCost = widget.totalCost;

    uploadOrderData(
      productIds: productIds,
      userId: userId,
      quantities: productQuantities,
      totalCost: totalCost,
    );

    clearUserCart(userId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SuccessPage()),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed: ${response.code} | ${response.message}");
  }

  Future<List<Map<String, dynamic>>> _fetchProductDetails() async {
    List<Map<String, dynamic>> products = [];

    for (String productId in widget.productQuantities.keys) {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        double price = productData['price'] is String
            ? double.tryParse(productData['price']) ?? 0.0
            : (productData['price'] is double ? productData['price'] : 0.0);

        productData['price'] = price;
        productData['quantity'] = widget.productQuantities[productId];
        products.add(productData);
      }
    }
    return products;
  }

  Future<void> uploadOrderData({
    required List<String> productIds,
    required String userId,
    required Map<String, int> quantities,
    required double totalCost,
  }) async {
    try {
      Map<String, dynamic> orderData = {
        'userId': userId,
        'productIds': productIds,
        'quantities': quantities,
        'totalCost': totalCost,
        'orderTime': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('Orders').add(orderData);
      print('Order uploaded successfully!');
      await _updateProductQuantities(quantities);
    } catch (e) {
      print('Failed to upload order: $e');
    }
  }

  Future<void> clearUserCart(String userId) async {
    try {
      CollectionReference cartProductsRef = FirebaseFirestore.instance
          .collection('Cart')
          .doc(userId)
          .collection('products');

      QuerySnapshot cartSnapshot = await cartProductsRef.get();

      if (cartSnapshot.docs.isEmpty) {
        print('Cart is already empty.');
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

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
      DocumentSnapshot productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        int? currentQuantity = productData['quantity'] is String
            ? int.tryParse(productData['quantity'])
            : (productData['quantity'] is int ? productData['quantity'] : 0);

        int newQuantity = (currentQuantity! - quantities[productId]!).clamp(0, currentQuantity);
        batch.update(productRef, {'quantity': newQuantity.toString()});
      }
    }

    await batch.commit();
    print('Product quantities updated successfully!');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375); // Adjust based on a base width
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text(
          translate('Order Summary'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFontSize(20)), // Smaller font size
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWaveSpinner(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading order details', style: TextStyle(fontSize: getResponsiveFontSize(14), color: Colors.red))); // Smaller font size
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No product details available', style: TextStyle(fontSize: getResponsiveFontSize(14)))); // Smaller font size
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
                      int quantity = product['quantity'];
                      double totalPrice = product['price'] * quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: Container(
                              width: screenWidth < 400 ? 50 : 80,
                              height: screenWidth < 400 ? 50 : 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product['img1Url'] ?? 'default_image_url',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              translate(product['name']),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFontSize(16)), // Smaller font size
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${translate('Price')}: ₹${product['price'].toStringAsFixed(2)}', style: TextStyle(fontSize: getResponsiveFontSize(14))), // Smaller font size
                                Text('${translate('Quantity')}: $quantity', style: TextStyle(fontSize: getResponsiveFontSize(14))), // Smaller font size
                                Text('${translate('Total')}: ₹${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: getResponsiveFontSize(14))), // Smaller font size
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${translate('Total Quantity')}: ${widget.totalQuantity}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFontSize(16)), // Smaller font size
                      ),
                      Text(
                        '${translate('Total Cost')}: ₹ ${widget.totalCost.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: getResponsiveFontSize(16)), // Smaller font size
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _openCheckout,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      child: Text(
                        translate('Confirm Order'),
                        style: TextStyle(fontSize: getResponsiveFontSize(18)), // Smaller font size
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
