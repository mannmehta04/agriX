import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> designationFinder(UserCredential userCredential) async {
  final String userId = userCredential.user?.uid ?? '';
  if (userId.isEmpty) {
    return null;
  }

  final firestoreInstance = FirebaseFirestore.instance;

  final farmerDoc = await firestoreInstance.collection('Farmers').doc(userId).get();
  if (farmerDoc.exists) {
    return 'Farmer';
  }

  final consumerDoc = await firestoreInstance.collection('Consumers').doc(userId).get();
  if (consumerDoc.exists) {
    return 'Consumer';
  }

  final adminDoc = await firestoreInstance.collection('Admin').doc(userId).get();
  if (adminDoc.exists) {
    return 'Admin';
  }

  return null;
}


Future<String> designation_Finder(User user) async {
  final String userId = user.uid;

  final firestoreInstance = FirebaseFirestore.instance;

  final farmerDoc = await firestoreInstance.collection('Farmers').doc(userId).get();
  if (farmerDoc.exists) {
    return 'Farmer';
  }

  final consumerDoc = await firestoreInstance.collection('Consumers').doc(userId).get();
  if (consumerDoc.exists) {
    return 'Consumer';
  }

  final adminDoc = await firestoreInstance.collection('Admin').doc(userId).get();
  if (adminDoc.exists) {
    return 'Admin';
  }

  return "";
}
