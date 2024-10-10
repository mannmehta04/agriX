import 'package:agrix/CartView.dart';
import 'package:agrix/Consumer/AccountDetails.dart';
import 'package:agrix/Consumer/ConsumerBase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../Consumer/CategorySearch.dart';

class ConsumerHome extends StatefulWidget {
  final String user;
  const ConsumerHome({super.key,required this.user});

  @override
  State<ConsumerHome> createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Consumerbase(),
    Cartview(cartId: FirebaseAuth.instance.currentUser!.uid),
    Accountdetails(user: FirebaseAuth.instance.currentUser!.uid),
    const Categorysearch(),
    Accountdetails(user: FirebaseAuth.instance.currentUser!.uid)
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

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   backgroundColor: Colors.black, // Set the background color
      //   selectedItemColor: Colors.green, // Color for selected item
      //   unselectedItemColor: Colors.grey[400], // Color for unselected items
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Cart',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.explore),
      //       label: 'Explore',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.category),
      //       label: 'Category',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_circle),
      //       label: 'Account',
      //     ),
      //   ],
      // ),
    );
  }
}