import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<String?> getFarmerNameById(String farmerId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore.instance
        .collection('Farmers')
        .doc(farmerId)
        .get();

    if (document.exists) {
      // Retrieve the 'name' field from the document data
      return document.data()?['firstName'];
    } else {
      print('No such document exists.');
      return null;
    }
  } catch (e) {
    print('Error fetching farmer data: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getConsumer() async {
  try {
    QuerySnapshot<Map<String, dynamic>> consumers = await FirebaseFirestore.instance
        .collection('Consumers')
        .get();

    List<Map<String, dynamic>> consumerList = consumers.docs.map((doc){ return {'id' : doc.id, ...doc.data() as  Map<String, dynamic>}; }).toList();

    return consumerList;
  } catch (e) {
    print("Error fetching consumers: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getFarmer() async {
  try {
    QuerySnapshot<Map<String, dynamic>> consumers = await FirebaseFirestore.instance
        .collection('Farmers')
        .get();

    List<Map<String, dynamic>> consumerList = consumers.docs.map((doc){ return {'id' : doc.id, ...doc.data() as  Map<String, dynamic>}; }).toList();

    return consumerList;
  } catch (e) {
    print("Error fetching consumers: $e");
    return [];
  }
}