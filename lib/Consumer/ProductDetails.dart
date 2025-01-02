import 'dart:math'; // Import for generating random numbers
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> item;

  const ProductDetails({Key? key, required this.item}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool isFavorited = false;
  late double randomRating;

  @override
  void initState() {
    super.initState();
    // Generate a random rating between 4.0 and 5.0
    randomRating = 4.0 + Random().nextDouble();
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  Future<void> addProductToCart(BuildContext context, String userId, String productId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      CollectionReference cartProducts = firestore.collection('Cart').doc(userId).collection('products');

      // Check if the product already exists in the cart
      DocumentSnapshot productInCart = await cartProducts.doc(productId).get();

      if (productInCart.exists) {
        // If the product exists, increment its quantity
        await cartProducts.doc(productId).update({
          'quantity': FieldValue.increment(1), // Increment quantity by 1
        });
      } else {
        // If the product doesn't exist, add it with quantity 1
        await cartProducts.doc(productId).set({
          'productId': productId,
          'quantity': 1, // Start with quantity 1
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AwesomeSnackbarContent(
            title: 'Success!',
            message: 'Product added to Cart successfully!',
            contentType: ContentType.success,
            inMaterialBanner: true,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Error adding product to Cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding product to Cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String id = widget.item['id'] ?? 'No id';
    final String name = widget.item['name'] ?? 'No Name';
    final String description = widget.item['desc'] ?? 'No Description';
    final double price = widget.item['price'] is String
        ? double.tryParse(widget.item['price']) ?? 0.0
        : widget.item['price']?.toDouble() ?? 0.0;
    final String unit = widget.item['unit'] ?? 'No Unit';
    final List images = [
      widget.item['img1Url'] ?? '',
      widget.item['img2Url'] ?? '',
      widget.item['img3Url'] ?? ''
    ].where((url) => url.isNotEmpty).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: images.isNotEmpty
                      ? CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.45, // Adjust height based on screen
                      viewportFraction: 1.0, // Full image fits within the screen width
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayCurve: Curves.easeInOut,
                      autoPlayAnimationDuration: const Duration(milliseconds: 1000), // Smoothen transition
                      clipBehavior: Clip.hardEdge,
                    ),
                    items: images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.0), // No gap between slides
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0), // Soft corner radius
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1), // Subtle shadow
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0), // Apply rounding to the image itself
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.grey, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: SpinKitWaveSpinner(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                      : Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    color: Colors.grey,
                    child: const Center(child: Text('No image available')),
                  ),
                ),
                Positioned(
                  top: 50.0,
                  left: 20.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // White background for back button
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black), // Black icon for contrast
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translate(name),
                        style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange),
                          Text(
                            randomRating.toStringAsFixed(1), // Randomized rating
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translate('About'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.black,
                          size: 30.0,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    translate(description),
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${translate('Price')}: ₹ ${price.toStringAsFixed(2)} / ${translate(unit)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹ ${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addProductToCart(context, FirebaseAuth.instance.currentUser!.uid, id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            translate('Add to Cart'),
                            style: const TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
