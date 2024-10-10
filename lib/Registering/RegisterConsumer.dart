import 'package:agrix/Home/ConsumerHome.dart';
import 'package:agrix/Registering/SignIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterConsumer extends StatefulWidget {
  const RegisterConsumer({super.key});

  @override
  State<RegisterConsumer> createState() => _RegisterConsumerState();
}

class _RegisterConsumerState extends State<RegisterConsumer> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final conformPasswordController = TextEditingController();
  final cityController = TextEditingController();

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

  Future<void> _uploadData(UserCredential userCredential) async {
    try {
      await FirebaseFirestore.instance.collection('Consumers').doc(userCredential.user!.uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'id': userCredential.user!.uid,
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
      print('Error uploading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error registering user: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sigUp(String email, String password) async {
    UserCredential? userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _uploadData(userCredential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConsumerHome(user: FirebaseAuth.instance.currentUser!.uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: e.message ?? 'Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return _isLoading
            ? const Center(child: SpinKitWaveSpinner(color: Colors.green))
            : Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  const SizedBox(height: 20.0),
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
                            _buildTextFormField('Last Name', 'Enter last name', Icons.people, TextInputType.text, lastNameController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Email', 'Enter your email', Icons.email, TextInputType.emailAddress, emailController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Phone Number', 'Enter your phone number', Icons.phone, TextInputType.phone, phoneController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('City', 'Enter your city', Icons.location_city_outlined, TextInputType.text, cityController),
                            const SizedBox(height: 16.0),
                            _buildTextFormField('Address', 'Enter your address', Icons.location_on, TextInputType.text, addressController),
                            const SizedBox(height: 16.0),
                            _buildPasswordFormField(controller: passwordController, labelText: 'Password', hintText: 'Enter your password'),
                            const SizedBox(height: 16.0),
                            _buildPasswordFormField(controller: conformPasswordController, labelText: 'Confirm Password', hintText: 'Confirm your password'),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  sigUp(emailController.text.trim(), passwordController.text.trim());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.black87, fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
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
        prefixIcon: const Icon(Icons.lock, color: Colors.black87),
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
    );
  }
}