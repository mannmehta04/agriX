import 'package:agrix/Consumer/PastOrders.dart';
import 'package:agrix/Farmer/ListedProducts.dart';
import 'package:agrix/Home/FarmerHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../Home/ConsumerHome.dart';
import '../preferences.dart';
import '../Registering/SignIn.dart';
import 'SalesTrack.dart';

class AccountdetailsF extends StatefulWidget {
  final String user;
  const AccountdetailsF({super.key, required this.user});

  @override
  State<AccountdetailsF> createState() => _AccountdetailsFState();
}

class _AccountdetailsFState extends State<AccountdetailsF> {
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    initializeFileData();
  }

  void initializeFileData() async {
    _isGujarati = Preferences.isEnglish;
  }

  Future<void> fetchUserData() async {
    try {
      print("tini call");
      final doc = await FirebaseFirestore.instance
          .collection('Farmers')
          .doc(widget.user)
          .get();

      if (doc.exists) {
        setState(() {
          final docDataWithId = {...doc.data()!, 'id': doc.id};
          userData = docDataWithId;
        });
      } else {
        print('No user found with this ID');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String fname = userData?['firstName'] ?? 'Unknown';
    String lname = userData?['lastName'] ?? 'Unknown';
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          translate('Account'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageSwitcher(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    '${translate('Hey')},\n$fname $lname',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 20.0,
                    crossAxisSpacing: 20.0,
                    childAspectRatio: 1.5,
                    children: [
                      _buildGridButton(translate('Orders'), Icons.shopping_cart_outlined, Colors.blue[100], (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Pastorders()));
                      }),
                      _buildGridButton(translate('Products'), Icons.storefront_outlined, Colors.blue[100], () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ListedProducts(user: FirebaseAuth.instance.currentUser!.uid)));
                      }),
                      _buildGridButton(translate('Sales'), Icons.people_outline, Colors.blue[100],() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Salestrack()));
                      }),
                      _buildGridButton(translate('Reports'), Icons.bar_chart_outlined, Colors.blue[100]),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  _logoutButton(translate('Log Out'), Icons.exit_to_app_outlined, Colors.redAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Locale _locale = const Locale('en', 'gu'); // Default locale set to 'en'

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Future<void> _switchLanguage(String languageCode) async {
    Locale newLocale = Locale(languageCode);
    await changeLocale(context, newLocale.languageCode);
    await Preferences.setLanguge(_isGujarati);

    setState(() {
      print('Language changed to: ${newLocale.languageCode}');
    });
    Navigator.pushReplacement(context, CupertinoDialogRoute(builder: (context) => FarmerHome(user: FirebaseAuth.instance.currentUser!.uid), context: context));
  }

  bool _isGujarati = true;

  void _showLanguageSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Switch Language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isGujarati = !_isGujarati;
                  });
                  if (_isGujarati) {
                    _switchLanguage('gu');
                  } else {
                    _switchLanguage('en');
                  }
                  Navigator.pop(context);
                },
                child: Text(_isGujarati ? 'English' : 'Gujarati'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridButton(String text, IconData icon, Color? color, [VoidCallback? onPressed]) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton(String text, IconData icon, Color color) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SignIn()),
                  (Route<dynamic> route) => false
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          minimumSize: const Size(200, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}