import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> fetchUser(String id,String desi) async {
  String user = FirebaseAuth.instance.currentUser!.uid;
  try {
    if(desi == "Consumer"){
      final doc = await FirebaseFirestore.instance
          .collection('Consumers')
          .doc(user)
          .get();
      String fname = doc['firstName'];
      String lname = doc['LastName'];
      String n = fname + ' ' +lname;
      return n;
    }
    if(desi == "Farmer"){
      final doc = await FirebaseFirestore.instance
          .collection('Farmers')
          .doc(id)
          .get();

      String fname = doc['firstName'];
      String lname = doc['LastName'];
      String n = fname + ' ' +lname;
      return n;
    }


  } catch (e) {
    print('Error fetching user data: $e');
  }
  return '';
}