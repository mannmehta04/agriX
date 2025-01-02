import 'dart:ffi';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class UpdateProduct extends StatefulWidget {
  final Map<String, dynamic> item;
  const UpdateProduct({super.key, required this.item});

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  void _updateField(String field, String currentValue) async {
    String? newValue = await _showUpdateDialog(field, currentValue);
    if (newValue != null && newValue.isNotEmpty) {
      // Updating the local state
      setState(() {
        widget.item[field] = field == 'price' ? double.tryParse(newValue) ?? 0.0 : newValue;
      });

      // Extracting product ID
      String productId = widget.item['id'];

      // Update the Firestore document
      try {
        await FirebaseFirestore.instance
            .collection('Products') // Ensure collection name matches in Firestore
            .doc(productId) // Document ID of the product
            .update({field: widget.item[field]});

        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field updated successfully!')),
        );
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $field: $e')),
        );
      }
    }
  }
  Future<void> _deleteProduct(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Products').doc(id).delete();
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<String?> _showUpdateDialog(String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Update $field')),
          content: TextField(
            controller: controller,
            keyboardType: field == 'price' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate('Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(translate('Update')),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.item['name'] ?? 'No Name';
    final String category = widget.item['category'] ?? 'No Category';
    final String description = widget.item['desc'] ?? 'No Description';
    final double price = widget.item['price'] is String
        ? double.tryParse(widget.item['price']) ?? 0.0
        : widget.item['price']?.toDouble() ?? 0.0;
    final String unit = widget.item['unit'] ?? 'No Unit';
    final String supplierName = widget.item['supplierName'] ?? '';
    final List images = [
      widget.item['img1Url'] ?? '',
      widget.item['img2Url'] ?? '',
      widget.item['img3Url'] ?? ''
    ].where((url) => url.isNotEmpty).toList();

    final Color supplierColor = supplierName.isNotEmpty ? Colors.black54 : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          translate('Product Details'),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Hero(
          tag: images.isNotEmpty ? images[0] : 'placeholder-tag',
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (images.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: images.length > 1
                              ? CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.width,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                              viewportFraction: 1.0,
                            ),
                            items: images.map((url) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: MediaQuery.of(context).size.width),
                                  );
                                },
                              );
                            }).toList(),
                          )
                              : Image.network(
                            images[0],
                            height: MediaQuery.of(context).size.width,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: MediaQuery.of(context).size.width),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16.0),
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _updateField('name', name),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${translate('Category')}: ${translate(category)}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _updateField('category', translate(category)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translate('About'),
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _updateField('desc', translate(description)), // Correct field name for description
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    translate(description),
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${translate('Price')}: ₹ ${price.toStringAsFixed(2)} / ${translate(unit)}',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _updateField('price', price.toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${translate('Supplier')}: ${supplierName.isNotEmpty ? supplierName : 'No Supplier yet'}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: supplierColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _updateField('supplierName', supplierName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      _deleteProduct(widget.item['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        translate('Delete Product'),
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}