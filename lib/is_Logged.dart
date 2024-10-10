import 'package:agrix/Home/AdminHome.dart';
import 'package:agrix/Home/ConsumerHome.dart';
import 'package:agrix/Home/FarmerHome.dart';
import 'package:agrix/Registering/DesignationFinder.dart';
import 'package:agrix/Registering/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class is_Logged extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Fetch the user role using the snapshot data
          return FutureBuilder<String>(
            future: designation_Finder(snapshot.data!),  // Pass the User object directly
            builder: (BuildContext context, AsyncSnapshot<String> roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: SpinKitWaveSpinner(color: Colors.green),
                  ),
                );
              } else if (roleSnapshot.hasData) {
                switch (roleSnapshot.data) {
                  case 'Farmer':
                    return FarmerHome(user: snapshot.data!.uid);
                  case 'Consumer':
                    return ConsumerHome(user: snapshot.data!.uid);
                  case 'Admin':
                    return AdminHome(user: snapshot.data!.uid);
                  default:
                    return SignIn();
                }
              } else {
                return SignIn();
              }
            },
          );
        } else {
          return SignIn();
        }
      },
    );
  }
}
