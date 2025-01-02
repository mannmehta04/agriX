import 'package:agrix/Consumer/ProductDetails.dart';
import 'package:agrix/Registering/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:agrix/Database%20Operations/FetchProducts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Registering/DesignationFinder.dart';

class Consumerbase extends StatefulWidget {
  const Consumerbase({super.key});

  @override
  State<Consumerbase> createState() => _ConsumerbaseState();
}

class _ConsumerbaseState extends State<Consumerbase> {
  late Future<List<Map<String, dynamic>>> data;
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String? userDesignation;

  @override
  void initState() {
    super.initState();
    data = getProducts();
    searchController.addListener(_filterProducts);
    _checkDesignation(); // Check user designation on init
  }

  Future<void> _checkDesignation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userDesignation = await designation_Finder(user);
      setState(() {});
    }
  }

  void _filterProducts() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        data = getProducts();
      } else {
        data = getProducts().then((products) => products.where((product) {
          final name = product['name']?.toLowerCase() ?? '';
          final price = product['price']?.toString() ?? '';
          return name.contains(query) || price.contains(query);
        }).toList());
      }
    });
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return Colors.white; // Default color
                  },
                ),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return Colors.red; // Default color
                  },
                ),
              ),
              child: const Text('Logout'),
              onPressed: () {
                _signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignIn(), // Replace with your login screen widget
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text(
          translate('agriX'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: userDesignation == 'Admin'
            ? [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: translate('Search Products'),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SpinKitWave(color: Colors.green));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(translate('No products available')));
                } else {
                  List<Map<String, dynamic>> products = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        data = getProducts();
                      });
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double width = constraints.maxWidth;
                        int crossAxisCount = width > 600 ? 3 : 2;
                        double cardWidth = (width - (crossAxisCount - 1) * 10) / crossAxisCount;
                        double cardHeight = cardWidth * 4 / 3;

                        return GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: cardWidth / cardHeight,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(item: product),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'tag-${product["img1Url"]}',
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: CachedNetworkImage(
                                          imageUrl: product['img1Url'] ?? '',
                                          height: cardHeight * 0.6,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: SpinKitWaveSpinner(
                                              color: Colors.green,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.broken_image,
                                            size: cardHeight * 0.6,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  translate('${product['name']}'),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.5,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹ ${product['price'] ?? '0.00'}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}