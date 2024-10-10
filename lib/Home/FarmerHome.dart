import 'package:agrix/CartView.dart';
import 'package:agrix/Consumer/CategorySearch.dart';
import 'package:agrix/Consumer/ConsumerBase.dart';
import 'package:agrix/Farmer/AccountDetails.dart';
import 'package:agrix/Farmer/AddProducts.dart';
import 'package:agrix/Farmer/FarmerBase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../Consumer/AccountDetails.dart';
import '../CartView.dart';

class FarmerHome extends StatefulWidget {
  final String user;
  const FarmerHome({super.key,required this.user});

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Consumerbase(),
    Cartview(cartId: FirebaseAuth.instance.currentUser!.uid),
    AccountdetailsF(user: FirebaseAuth.instance.currentUser!.uid),
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
            // inactiveColor: Colors.black12,
            icon: Icon(Icons.home),
            title: Text(translate('Home')),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.shopping_cart),
            title: Text(translate('Cart')),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.explore),
            title: Text(translate('Explore')),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.category),
            title: Text(translate('Category')),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.account_circle),
            title: Text(translate('Account')),
          ),
        ],
      ),
    );
  }
}
