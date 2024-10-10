import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AddProducts extends StatefulWidget {
  final String user;
  const AddProducts({super.key, required this.user});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryAddress = TextEditingController();
  String? type;
  String? unit;
  bool _isLoading = false;

  final List<String> category = [
    "Fruit", "Vegetable", "Leafy Greens", "Root Vegetables", "Herbs",
    "Grains", "Legumes", "Berries", "Tubers", "Nuts", "Mushrooms"
  ];

  final List<String> units = [
    "Kg", "Dozen", "Gram", "Pound", "Bunch", "Piece", "Liter", "Pint", "Box"
  ];

  File? _image1;
  File? _image2;
  File? _image3;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int imageNumber) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else if (imageNumber == 2) {
          _image2 = File(pickedFile.path);
        } else if (imageNumber == 3) {
          _image3 = File(pickedFile.path);
        }
      }
    });
  }

  Future<String?> _uploadImage(File? image, String productId, int imageNumber) async {
    if (image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('products/$productId/image$imageNumber.jpg');
      final uploadTask = await storageRef.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image $imageNumber: $e');
      return null;
    }
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      final productId = FirebaseFirestore.instance.collection('Products').doc().id;

      String? imageUrl1 = await _uploadImage(_image1, productId, 1);
      String? imageUrl2 = await _uploadImage(_image2, productId, 2);
      String? imageUrl3 = await _uploadImage(_image3, productId, 3);

      FirebaseFirestore.instance.collection('Products').doc(productId).set({
        'name': _nameController.text,
        'category': type,
        'desc': _descController.text,
        'price': _priceController.text,
        'unit': unit,
        'quantity': _quantityController.text,
        'deliveryAddress': _deliveryAddress.text,
        'ima1Url': imageUrl1,
        'ima2Url': imageUrl2,
        'ima3Url': imageUrl3,
        'user_id': widget.user,
        'createdAt': DateTime.now()
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $error')),
        );
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: SpinKitWaveSpinner(color: Colors.green),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    'Product Name',
                    'Enter product name',
                    _nameController,
                    icon: Icons.production_quantity_limits,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDropdownFormField(
                    'Category',
                    'Select category',
                    category,
                    type,
                        (newValue) => setState(() {
                      type = newValue;
                    }),
                    icon: Icons.category,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFormField(
                    'Description',
                    'Enter description',
                    _descController,
                    maxLines: 3,
                    icon: Icons.description,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          'Price',
                          'Enter price',
                          _priceController,
                          inputType: TextInputType.number,
                          icon: Icons.attach_money,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: _buildDropdownFormField(
                          'Unit',
                          'Select unit',
                          units,
                          unit,
                              (newValue) => setState(() {
                            unit = newValue;
                          }),
                          icon: Icons.tab_unselected_rounded,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFormField(
                    'Quantity',
                    'Enter quantity',
                    _quantityController,
                    inputType: TextInputType.number,
                    icon: Icons.format_list_numbered,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextFormField(
                    'Delivery Address',
                    'Enter delivery address',
                    _deliveryAddress,
                    inputType: TextInputType.streetAddress,
                    icon: Icons.location_on,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _imagePickerButton(1)),
                      Flexible(child: _imagePickerButton(2)),
                      Flexible(child: _imagePickerButton(3)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                      child: Text(
                        'Save Product',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildTextFormField(
      String label,
      String hintText,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        int maxLines = 1,
        required IconData icon,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        contentPadding: const EdgeInsets.all(16.0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownFormField(
      String label,
      String hintText,
      List<String> items,
      String? selectedItem,
      ValueChanged<String?> onChanged, {
        required IconData icon,
      }) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        contentPadding: const EdgeInsets.all(16.0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _imagePickerButton(int imageNumber) {
    return GestureDetector(
      onTap: () => _pickImage(imageNumber),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: _getImageWidget(imageNumber),
        ),
      ),
    );
  }

  Widget _getImageWidget(int imageNumber) {
    File? image;
    if (imageNumber == 1) image = _image1;
    if (imageNumber == 2) image = _image2;
    if (imageNumber == 3) image = _image3;

    if (image != null) {
      return Image.file(image, fit: BoxFit.cover);
    } else {
      return Icon(Icons.add_a_photo, color: Colors.green[700]);
    }
  }
}
