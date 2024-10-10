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
  late List<String> productIds;

  @override
  bool get wantKeepAlive => false; // Ensure page doesn't retain state when revisited

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

        // Reference to the document
        final docRef = FirebaseFirestore.instance
            .collection('Cart')
            .doc(userId)
            .collection('products')
            .doc(id);

        // Check if the document exists
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

  Future<void> getProductIds() async {
    List<String> productIds = await _productIdsFuture;
    print(productIds);
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  void getProducts(){
    _productIdsFuture =
        fetchProductIdsFromCart(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the keep-alive functionality is applied

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          translate('Cart'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _productIdsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWaveSpinner(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading cart'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your cart is empty'));
          }

          List<String> productIds = snapshot.data!;

          return FutureBuilder<List<CartProduct>>(
            future: fetchProductsByIds(
                productIds, FirebaseAuth.instance.currentUser!.uid),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SpinKitWaveSpinner(color: Colors.green));
              } else if (productSnapshot.hasError) {
                return Center(child: Text('Error loading products'));
              } else if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                getProducts();
                return Center(child: Text('No products found'));
              }

              List<CartProduct> cartProducts = productSnapshot.data!;

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
                        return ListTile(
                          leading: Image.network(
                            product.img1Url ??
                                product.img2Url ??
                                product.img3Url ??
                                'default_image_url',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(translate('${product.name}')),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${translate('Price')}: ${translate('₹')} ${product.price.toStringAsFixed(2)}'
                              ),
                              Text(
                                  '${translate('Total')}: ${translate('₹')} ${product.totalPrice.toStringAsFixed(2)}'
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    quantity -= 1;
                                    _checkQuantity(product.productId,quantity);
                                    _updateQuantity(product.productId, -1);
                                  });
                                },
                              ),
                              Text(
                                '${quantity}',
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    quantity += 1;
                                    _checkQuantity(product.productId,quantity);
                                    _updateQuantity(product.productId, 1);
                                  });
                                },
                              ),
                            ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${translate('Total Quantity')}: $totalQuantity',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              '${translate('Total Cost')}: ${translate('₹')} ${totalCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Buy Now Button
                        ElevatedButton(
                          onPressed: () async {
                            getProductIds();
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
                          child: Text(translate('Buy Now')),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green, // Button color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
