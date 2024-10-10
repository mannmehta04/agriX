import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getProducts({String? userId, String? category}) async {
  try {
    CollectionReference productsCollection = FirebaseFirestore.instance.collection('Products');

    Query query = productsCollection;

    if (userId != null) {
      query = query.where('user_id', isEqualTo: userId);
    }

    // If category is provided, filter by category
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    QuerySnapshot querySnapshot = await query.get();

    // Include the document ID in the map
    List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID
      return data;
    }).toList();

    print(products);
    return products;
  } catch (e) {
    print('Error getting products: $e');
    return [];
  }
}