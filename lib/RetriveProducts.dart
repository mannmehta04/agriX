import 'package:cloud_firestore/cloud_firestore.dart';

import 'CartProduct.dart';

Future<List<String>> fetchProductIdsFromCart(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Fetch product IDs from sub-collection 'products'
    QuerySnapshot productDocs = await firestore
        .collection('Cart')
        .doc(userId)
        .collection('products')
        .get();

    if (productDocs.docs.isNotEmpty) {
      List<String> productIds = productDocs.docs.map((doc) => doc.id).toList();
      print("Product IDs: $productIds"); // Debugging: Print fetched product IDs
      return productIds;
    } else {
      print("No products found in cart");
      return [];
    }
  } catch (e) {
    print('Error fetching product IDs from Cart: $e');
    return [];
  }
}

Future<List<CartProduct>> fetchProductsByIds(List<String> productIds, String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<CartProduct> cartProducts = [];

  try {
    for (String productId in productIds) {
      // Fetch product details
      DocumentSnapshot productSnapshot = await firestore.collection('Products').doc(productId).get();

      if (productSnapshot.exists) {
        // Fetch quantity from the 'products' sub-collection in the 'Cart'
        DocumentSnapshot cartProductSnapshot = await firestore
            .collection('Cart')
            .doc(userId)
            .collection('products')
            .doc(productId)
            .get();

        int quantity = cartProductSnapshot.exists ? (cartProductSnapshot.data() as Map<String, dynamic>)['quantity'] : 1;

        CartProduct product = CartProduct.fromDocument(productSnapshot, quantity);
        cartProducts.add(product);
        print("Fetched product: ${product.name}"); // Debugging: Print fetched product name
      } else {
        print("Product with ID $productId does not exist.");
      }
    }
  } catch (e) {
    print('Error fetching product details: $e');
  }

  return cartProducts;
}

Future<Map<String, dynamic>> fetchProductById(String productId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic> productData = {};

  try {
    // Fetch product details
    DocumentSnapshot productSnapshot = await firestore.collection('Products').doc(productId).get();

    if (productSnapshot.exists) {
      // Extract product data and store it in productData map
      productData = productSnapshot.data() as Map<String, dynamic>;
    } else {
      print('Product not found');
    }
  } catch (e) {
    print('Error fetching product details: $e');
  }

  return productData;
}
