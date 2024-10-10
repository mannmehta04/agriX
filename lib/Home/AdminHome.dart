import 'package:agrix/Admin/ConsumersList.dart';
import 'package:agrix/Admin/FarmersList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

import '../Consumer/ConsumerBase.dart';

class AdminHome extends StatefulWidget {
  final String user;
  const AdminHome({super.key,required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final List<Widget> _pages = [
    const Consumerbase(),
    ConsumersList(),
    FarmersList()
  ];
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
            title: Text("Home"),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.person),
            title: Text("Consumer"),
          ),
          FlashyTabBarItem(
            activeColor: Colors.green,
            icon: Icon(Icons.agriculture),
            title: Text("Farmer"),
          ),
        ],
      ),
    );
  }
}
