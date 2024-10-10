import 'package:agrix/Home/ConsumerHome.dart';
import 'package:agrix/Home/FarmerHome.dart';
import 'package:agrix/Registering/DesignationFinder.dart';
import 'package:agrix/Registering/Redirect.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Home/AdminHome.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  final formKey = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));

    animationController.forward();
  }

  Future<void> sigIn(String email, String password) async {
    if (formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        UserCredential? userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (userCredential == null || userCredential.user == null) {
          Fluttertoast.showToast(
            msg: "User sign-in failed, please try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        String? iAm = await designationFinder(userCredential);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (iAm == "Farmer") {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => FarmerHome(user: FirebaseAuth.instance.currentUser!.uid,)),
                  (route) => false,
            );
          } else if (iAm == "Consumer") {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ConsumerHome(user: FirebaseAuth.instance.currentUser!.uid,)),
                  (route) => false,
            );
          } else if (iAm == "Admin") {
            setState(() {
              _isLoading = false;
            });
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminHome(user: FirebaseAuth.instance.currentUser!.uid,)),
                  (route) => false,
            );
          } else {
            setState(() {
              _isLoading = false;
            });
            Fluttertoast.showToast(
              msg: "User role not found.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'too-many-requests') {
          Fluttertoast.showToast(
            msg: "Too many attempts. Please try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (e.code == 'app-check-error') {
          Fluttertoast.showToast(
            msg: "Error validating App Check token. Please try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: e.code.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, child) {
        return _isLoading ? Center(child: SpinKitWaveSpinner(color: Colors.green)) :
        Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20.0),
                        FadeTransition(
                          opacity: fadeAnimation,
                          child: const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        FadeTransition(
                          opacity: fadeAnimation,
                          child: const Text(
                            'Whether you\'re here to grow your farm or find fresh produce, sign in to continue. Manage your contracts, track your harvest, or discover the best local produce with ease.',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        FadeTransition(
                          opacity: fadeAnimation,
                          child: Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    focusNode: emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      labelText: 'Email',
                                      prefixIcon: const Icon(
                                        Icons.email_rounded,
                                        color: Colors.black87,
                                      ),
                                      errorStyle: const TextStyle(fontSize: 18.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.green),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.green,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex = RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocusNode);
                                    },
                                  ),
                                  const SizedBox(height: 20.0),
                                  TextFormField(
                                    controller: passwordController,
                                    focusNode: passwordFocusNode,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons.password_rounded,
                                        color: Colors.black87,
                                      ),
                                      errorStyle: const TextStyle(fontSize: 18.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(color: Colors.green),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.green,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20.0),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      child: const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.none,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      onTap: () {
                                        _ForgotPassword(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  FadeTransition(
                                    opacity: fadeAnimation,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          sigIn(emailController.value.text.toString(), passwordController.value.text.toString());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40.0,
                                            vertical: 20.0),
                                      ),
                                      child: const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FadeTransition(
                                    opacity: fadeAnimation,
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          const TextSpan(
                                            text: 'Don\'t have an account? ',
                                            style: TextStyle(
                                                color: Colors.black87, fontSize: 15),
                                          ),
                                          TextSpan(
                                            text: 'Register Now',
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Redirect(),
                                                ),
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
                        ),
                      ],
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

  void _ForgotPassword(BuildContext context) {
    String email = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter your Email'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_rounded, color: Colors.black),
                      hintText: 'Enter E-mail',
                      label: const Text('E-mail'),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.green,
                              width: 2.0
                          ),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0,),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (email.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please Enter Email",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    } else {
                      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    passwordController.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}
