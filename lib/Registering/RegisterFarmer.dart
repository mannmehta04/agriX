import 'dart:io';

import 'package:agrix/Home/FarmerHome.dart';
import 'package:agrix/Registering/SignIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class Registerfarmer extends StatefulWidget {
  const Registerfarmer({super.key});

  @override
  State<Registerfarmer> createState() => _RegisterfarmerState();
}

class _RegisterfarmerState extends State<Registerfarmer> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final conformPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final adharController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  String? _soilDNAFileName;
  String? _pancardFileName;
  String? _aadhaarFileName;

  PlatformFile? _aadhaarFile;
  PlatformFile? _panFile;
  PlatformFile? _soilFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String fileType) async {
    if (await Permission.storage.request().isGranted) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.isNotEmpty) {
          switch (fileType) {
            case 'aadhaar':
              _aadhaarFile = result.files.single;
              _aadhaarFileName = result.files.single.name;
              break;
            case 'pan':
              _panFile = result.files.single;
              _pancardFileName = result.files.single.name;
              break;
            case 'soildna':
              _soilFile = result.files.single;
              _soilDNAFileName = result.files.single.name;
              break;
          }
          setState(() {

          });
          print('Selected $fileType file: ${result.files.single.name}');
        } else {
          throw Exception('File selection cancelled');
        }
      } catch (e) {
        print('Error picking file: $e');
        throw Exception('Error picking file: $e');
      }
    } else {
      throw Exception('Storage permission not granted');
    }
  }

  Future<void> _uploadData(UserCredential userCredential) async {
    try {
      if (_aadhaarFile == null || _panFile == null || _soilFile == null) {
        throw Exception('Please upload all required files');
      }
      // String uId  = FirebaseAuth.instance.currentUser?.uid ?? "Error";

      // String aadhaarFilePath = '$uId/aadhaar/${_aadhaarFile?.name??''}';
      String aadhaarFilePath = 'aadhaar/${_aadhaarFile?.name??''}';
      UploadTask aadhaarUploadTask = FirebaseStorage.instance.ref(aadhaarFilePath).putFile(File(_aadhaarFile?.path??''));
      String aadhaarDownloadUrl = await (await aadhaarUploadTask).ref.getDownloadURL();

      // String panFilePath = '$uId/pan/${_panFile?.name??''}';
      String panFilePath = 'pan/${_panFile?.name??''}';
      UploadTask panUploadTask = FirebaseStorage.instance.ref(panFilePath).putFile(File(_panFile?.path??''));
      String panDownloadUrl = await (await panUploadTask).ref.getDownloadURL();

      // String soilFilePath = '$uId/soil/${_soilFile?.name??''}';
      String soilFilePath = 'soil/${_soilFile?.name??''}';
      UploadTask soilUploadTask = FirebaseStorage.instance.ref(soilFilePath).putFile(File(_soilFile?.path??''));
      String soilDownloadUrl = await (await soilUploadTask).ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('Farmers').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'aadhaarNo': adharController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'address': addressController.text,
        'city': cityController.text,
        'aadhaarUrl': aadhaarDownloadUrl,
        'panUrl': panDownloadUrl,
        'soilUrl': soilDownloadUrl,
      });
      await FirebaseFirestore.instance.collection('Cart')
          .doc(userCredential.user!.uid)  // Document with user ID
          .collection('products')  // Subcollection 'products'
          .doc()  // Creating a product document (you can later use a specific product ID)
          .set({
        // 'product': 'Example Product',
        // 'price': 100,
        // 'quantity': 1,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
        _aadhaarFile = null;
        _panFile = null;
        _soilFile = null;
      });
    }
  }

  Future<void> sigUp(BuildContext context, String email, String password) async {
    setState(() {
      _isLoading = false;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await _uploadData(userCredential);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FarmerHome(user: FirebaseAuth.instance.currentUser!.uid)));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? 'An error occurred',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing up: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return _isLoading
            ? const Center(child: SpinKitWaveSpinner(color: Colors.green))
            : Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60.0),
                  FadeTransition(
                    opacity: opacityAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: const Text(
                        'Let\'s get started!',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: opacityAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextFormField('First Name', 'Enter first name', Icons.person, TextInputType.text, firstNameController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Last Name', 'Enter last name', Icons.person, TextInputType.text, lastNameController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('E-mail', 'Enter e-mail', Icons.email, TextInputType.emailAddress, emailController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Phone', 'Enter phone number', Icons.call, TextInputType.number, phoneController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Aadhaar No', 'Enter Aadhaar number', Icons.perm_identity, TextInputType.number, adharController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('City', 'Enter your city', Icons.location_city_outlined, TextInputType.streetAddress, cityController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Address', 'Enter your address', Icons.location_city, TextInputType.streetAddress, addressController),
                            const SizedBox(height: 16.0),
                            _buildPasswordFormField(controller: passwordController, labelText: 'Password', hintText: 'Enter your password'),
                            const SizedBox(height: 16.0),
                            _buildPasswordFormField(controller: conformPasswordController, labelText: 'Confirm Password', hintText: 'Confirm your password'),
                            const SizedBox(height: 16.0),
                            FadeTransition(
                              opacity: opacityAnimation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: _buildFilePicker('Aadhaar Card', _aadhaarFileName, () => _pickFile('aadhaar')),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            FadeTransition(
                              opacity: opacityAnimation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: _buildFilePicker('PAN Card', _pancardFileName, () => _pickFile('pan')),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            FadeTransition(
                              opacity: opacityAnimation,
                              child: ScaleTransition(
                                scale: scaleAnimation,
                                child: _buildFilePicker('Soil DNA', _soilDNAFileName, () => _pickFile('soildna')),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_aadhaarFile != null && _panFile != null && _soilFile != null) {
                                    await sigUp(context, emailController.text.trim(), passwordController.text.trim());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload all required files.')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                              ),
                              child: const Text('Get Started', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                            ),
                            const SizedBox(height: 20.0),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.black87, fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SignIn()),
                                      ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
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
  }

  TextFormField _buildTextFormField(String labelText, String hintText, IconData icon, TextInputType keyboardType, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.black87),
        errorStyle: const TextStyle(fontSize: 16.0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Please enter $labelText' : null,
    );
  }

  TextFormField _buildPasswordFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: const Icon(Icons.password_rounded, color: Colors.black87),
        errorStyle: const TextStyle(fontSize: 16.0),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $labelText' : null,
    );
  }

  Widget _buildFilePicker(String labelText, String? fileName, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Pick File', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Text(fileName ?? 'No file selected', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      ],
    );
  }
}