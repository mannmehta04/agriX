import 'package:agrix/OrderSummary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'CartProduct.dart';
import 'RetriveProducts.dart';

class Cartview extends StatefulWidget {
  final String cartId;
  const Cartview({super.key, required this.cartId});

  @override
  State<Cartview> createState() => _CartviewState();
}

class _CartviewState extends State<Cartview> with AutomaticKeepAliveClientMixin {
  late Future<List<String>> _productIdsFuture;
  int totalQuantity = 0;
  double totalCost = 0.0;

  @override
  bool get wantKeepAlive => false;

  Future<void> _updateQuantity(String id, int i) async {
    try {
      await FirebaseFirestore.instance
          .collection('Cart')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('products')
          .doc(id)
          .update({
        'quantity': FieldValue.increment(i),
      });
      setState(() {
        _productIdsFuture = fetchProductIdsFromCart(FirebaseAuth.instance.currentUser!.uid);
      });
    } catch (e) {
      print('Exception Caught: $e');
    }
  }

  Future<void> _checkQuantity(String id, int quantity) async {
    if (quantity == 0) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId == null) {
          print('Error: User not logged in.');
          return;
        }

        final docRef = FirebaseFirestore.instance
            .collection('Cart')
            .doc(userId)
            .collection('products')
            .doc(id);

        final doc = await docRef.get();

        if (doc.exists) {
          print('Document exists. Deleting...');
          await docRef.delete();
          print('Product with id $id deleted from cart.');
        } else {
          print('Error: Product with id $id does not exist.');
        }
      } catch (e) {
        print('Error caught while deleting product: $e');
      }
    } else {
      print('Quantity is not zero, no need to delete.');
    }
  }

  Future<void> getProducts() async {
    _productIdsFuture =
        fetchProductIdsFromCart(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          translate('Cart'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _productIdsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitWaveSpinner(
                color: Colors.green,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading cart',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            );
          }

          List<String> productIds = snapshot.data ?? [];

          if (productIds.isEmpty) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: MediaQuery.of(context).size.width * 0.25,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      translate('Your cart is empty!'),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      translate('Add products to see them here'),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        _refresh();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.05,
                      ),
                      label: Text(
                        translate('Refresh'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<CartProduct>>(
              future: fetchProductsByIds(
                  productIds, FirebaseAuth.instance.currentUser!.uid),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitWaveSpinner(
                      color: Colors.green,
                    ),
                  );
                } else if (productSnapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading products',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                List<CartProduct> cartProducts = productSnapshot.data ?? [];

                // Calculate total quantity and total cost
                totalQuantity = cartProducts.fold(
                    0, (sum, product) => sum + product.quantity);
                totalCost = cartProducts.fold(
                    0, (sum, product) => sum + product.totalPrice);

                return Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                        itemCount: cartProducts.length,
                        itemBuilder: (context, index) {
                          CartProduct product = cartProducts[index];
                          int quantity = product.quantity;
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.img1Url ?? product.img2Url ?? product.img3Url ?? 'default_image_url',
                                  width: MediaQuery.of(context).size.width * 0.15,
                                  height: MediaQuery.of(context).size.width * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                translate(product.name),
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${translate('Price')}: ${translate('₹')} ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${translate('Total')}: ${translate('₹')} ${product.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.035,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          quantity -= 1;
                                          _checkQuantity(product.productId, quantity);
                                          _updateQuantity(product.productId, -1);
                                        });
                                      },
                                    ),
                                    Text(
                                      '${quantity}',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          quantity += 1;
                                          _checkQuantity(product.productId, quantity);
                                          _updateQuantity(product.productId, 1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Total Quantity and Total Cost Display
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${translate('Total Quantity')}: $totalQuantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                  ),
                                ),
                                Text(
                                  '${translate('Total Cost')}: ${translate('₹')} ${totalCost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Buy Now Button
                          ElevatedButton(
                            onPressed: () async {
                              Map<String, int> productQuantities = {};
                              for (var product in cartProducts) {
                                productQuantities[product.productId] = product.quantity;
                              }
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Ordersummary(
                                    productQuantities: productQuantities,
                                    totalCost: totalCost,
                                    totalQuantity: totalQuantity,
                                  ),
                                ),
                              ).whenComplete(() => setState(() {}));
                            },
                            child: Text(
                              translate('Buy Now'),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 3,
                              textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}