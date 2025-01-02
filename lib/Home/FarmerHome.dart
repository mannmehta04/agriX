import 'package:agrix/CartView.dart';
import 'package:agrix/Consumer/CategorySearch.dart';
import 'package:agrix/Consumer/ConsumerBase.dart';
import 'package:agrix/ExplorePage.dart';
import 'package:agrix/Farmer/AccountDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../Consumer/AccountDetails.dart';
import '../CartView.dart';

class FarmerHome extends StatefulWidget {
  final String user;
  const FarmerHome({super.key, required this.user});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Consumerbase(),
    Cartview(cartId: FirebaseAuth.instance.currentUser!.uid),
    ExplorePage(),
    Categorysearch(),
    AccountdetailsF(user: FirebaseAuth.instance.currentUser!.uid),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width * 0.07;
    double fontSize = MediaQuery.of(context).size.width * 0.035;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeOutQuad,
        items: [
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.home, size: iconSize),
            title: Text(translate('Home'), style: TextStyle(fontSize: fontSize)),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.shopping_cart, size: iconSize),
            title: Text(translate('Cart'), style: TextStyle(fontSize: fontSize)),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.explore, size: iconSize),
            title: Text(translate('Explore'), style: TextStyle(fontSize: fontSize)),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.category, size: iconSize),
            title: Text(translate('Category'), style: TextStyle(fontSize: fontSize)),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.account_circle, size: iconSize),
            title: Text(translate('Account'), style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }
}
