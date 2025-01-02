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
  final PageStorageBucket _bucket = PageStorageBucket();

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Widget> _pages = [
    const Consumerbase(key: PageStorageKey('Home')),
    ConsumersList(key: PageStorageKey('ConsumerList')),
    FarmersList(key: PageStorageKey('FarmersList'))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeOutQuad,
        items: [
          FlashyTabBarItem(
            activeColor: Colors.green,
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
