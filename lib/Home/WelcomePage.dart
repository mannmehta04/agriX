import 'package:agrix/Registering/SignIn.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation, delayedAnimation, muchDelayedAnimation, muchMuchDelayedAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    animation = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));
    delayedAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: animationController, curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn)));
    muchDelayedAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: animationController, curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));
    muchMuchDelayedAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: animationController, curve: const Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  transform: Matrix4.translationValues(animation.value * width, 0.0, 0.0),
                  child: const Text(
                    'Welcome to agriX!',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20.0),
                Transform(
                  transform: Matrix4.translationValues(delayedAnimation.value * width, 0.0, 0.0),
                  child: const Text(
                    'We\'re excited to have you on board. At agriX, we connect farmers and partners for successful, contract-based farming.',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20.0),
                Transform(
                  transform: Matrix4.translationValues(muchDelayedAnimation.value * width, 0.0, 0.0),
                  child: const Text(
                    'Manage your contracts, connect with reliable partners, and access valuable resources—all in one place.',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20.0),
                Transform(
                  transform: Matrix4.translationValues(muchMuchDelayedAnimation.value * width, 0.0, 0.0),
                  child: const Text(
                    'Here\'s to your success!',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40.0),
                Transform(
                  transform: Matrix4.translationValues(muchMuchDelayedAnimation.value * width, 0.0, 0.0),
                  child: const Text(
                    'Warm regards,\nThe agriX Team',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40.0),
                Transform(
                  transform: Matrix4.translationValues(muchMuchDelayedAnimation.value * width, 0.0, 0.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SignIn(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0), // Button padding
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
