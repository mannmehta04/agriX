import 'package:agrix/Home/ConsumerHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 120,
              ),
              SizedBox(height: 30),
              // Success Text
              Text(
                translate('Order Placed Successfully!'),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                translate('Your order has been placed successfully and is now being processed. Thank you for shopping with us!'),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // "Continue Shopping" or "Go to Home" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.of(context).popUntil((route) => route.isFirst);
                  // // Reinitialize the app by clearing the entire stack and navigating to home
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConsumerHome(user: FirebaseAuth.instance.currentUser!.uid)));
                },
                child: Text(translate('Go to Home')),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: Colors.green, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Optional: Add any other action buttons like "View Order" or "Track Order"
              // TextButton(
              //   onPressed: () {
              //     // Add action to view or track order
              //   },
              //   child: Text(
              //     'View Order Details',
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Colors.green,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
