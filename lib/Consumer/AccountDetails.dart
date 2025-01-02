import 'package:agrix/Consumer/UpdateDetails.dart';
import 'package:agrix/Home/ConsumerHome.dart';
import 'package:agrix/Registering/SignIn.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../preferences.dart';
import 'PastOrders.dart';

class Accountdetails extends StatefulWidget {
  final String user;
  const Accountdetails({super.key, required this.user});

  @override
  State<Accountdetails> createState() => _AccountdetailsState();
}

class _AccountdetailsState extends State<Accountdetails> {
  late Map<String, dynamic> userData;
  List<File?> selectedFiles = [];
  List<String> fileNames = [];
  List<bool> fileUploaded = [];
  bool isUploading = false;

  final List<String> requiredDocuments = [
    translate("Aadhar Card"),
    translate("PAN Card"),
    translate("Land Certificate")
  ];

  @override
  void initState() {
    super.initState();
    initializeFileData();
    fetchUserData();
  }

  void initializeFileData() async{
    _isGujarati = Preferences.isEnglish;
    selectedFiles = List<File?>.filled(requiredDocuments.length, null);
    fileNames = List<String>.from(requiredDocuments.map((doc) => translate(doc)));
    fileUploaded = List<bool>.filled(requiredDocuments.length, false);
  }

  Future<void> fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Consumers')
          .doc(widget.user)
          .get();

      if (doc.exists) {
        setState(() {
          final docDataWithId = {...doc.data()!, 'id': doc.id};
          userData = docDataWithId;
          print(userData);
        });
      } else {
        print('No user found with this ID');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> pickFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png'],
      );

      if (result != null) {
        setState(() {
          selectedFiles[index] = File(result.files.single.path!);
          fileNames[index] = result.files.single.name;
          fileUploaded[index] = false;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> uploadFiles() async {
    setState(() {
      isUploading = true;
    });

    try {
      if (selectedFiles.every((file) => file != null)) {
        List<String> documentUrls = [];

        for (var i = 0; i < selectedFiles.length; i++) {
          String folderName = requiredDocuments[i].toLowerCase();
          String fileName = fileNames[i];

          var ref = FirebaseStorage.instance
              .ref()
              .child('$folderName/')
              .child(fileName);
          var uploadTask = await ref.putFile(selectedFiles[i]!);
          String downloadUrl = await uploadTask.ref.getDownloadURL();

          documentUrls.add(downloadUrl);

          setState(() {
            fileUploaded[i] = true;
          });
        }

        Map<String, dynamic> farmerData = {...userData!};
        farmerData['documentUrls'] = documentUrls;
        farmerData['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('Farmers')
            .doc(widget.user)
            .set(farmerData);

        await FirebaseFirestore.instance
            .collection('Consumers')
            .doc(widget.user)
            .delete();

        Fluttertoast.showToast(
          msg: "Successfully became a farmer! Please log in as a farmer.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        await FirebaseAuth.instance.signOut();

        Future.microtask(() {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
        });

        print("Successfully became a farmer!");
      } else {
        print("Please select all documents before submitting.");
      }
    } catch (e) {
      print('Error uploading files: $e');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fname = userData?['firstName'] ?? '';
    String lname = userData?['lastName'] ?? '';
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          translate('Account'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      int crossAxisCount = width > 600 ? 3 : 2;
                      double cardWidth = (width - (crossAxisCount - 1) * 20) / crossAxisCount;
                      double cardHeight = cardWidth * 0.8;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20.0,
                          mainAxisSpacing: 20.0,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return _buildGridButton(translate('Orders'), Icons.shopping_cart_outlined, Colors.blue[100], (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Pastorders()));
                              });
                            case 1:
                              return _buildGridButton(translate('Products'), Icons.storefront_outlined, Colors.blue[100], () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: AwesomeSnackbarContent(
                                      title: translate('Wait!'),
                                      message: (_isGujarati)? 'ઉત્પાદન સૂચિ માટે ખેડૂત બનો' : 'Become Farmer to see List Products',
                                      contentType: ContentType.help,
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
                              });
                            case 2:
                              return _buildGridButton(translate('Customer'), Icons.people_outline, Colors.blue[100], () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: AwesomeSnackbarContent(
                                      title: translate('Wait!'),
                                      message: (_isGujarati)? 'ગ્રાહક વેચાણ જોવા માટે ખેડૂત બનો' : 'Become Farmer to see Customer Sales',
                                      contentType: ContentType.help,
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
                              });
                            case 3:
                              return _buildGridButton(translate('Sales Report'), Icons.bar_chart_outlined, Colors.blue[100], () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: AwesomeSnackbarContent(
                                      title: translate('Wait!'),
                                      message: (_isGujarati)? 'વેચાણ રિપોર્ટ જોવા માટે ખેડૂત બનો' : 'Become Farmer to see Sales Report',
                                      contentType: ContentType.help,
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
                              });
                            case 4:
                              return _buildGridButton(translate('Account Details'), Icons.person, Colors.blue[100], () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Updatedetails(consumer: userData)));
                              });
                            case 5:
                              return _buildGridButton(translate('Become a Farmer'), Icons.agriculture_outlined, Colors.greenAccent, () {
                                _showFilePickerCard(context);
                              });
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40.0),
                  _logoutButton('Log Out', Icons.exit_to_app_outlined, Colors.redAccent),
                ],
              ),
            ),
          ),
          if (isUploading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AwesomeSnackbarContent(
              title: translate('Success'),
              message: (_isGujarati)? 'ભાષા ગુજરાતી માં બદલાયેલ છે' : 'Language changed to English!',
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
    });
    Navigator.pushReplacement(context, CupertinoDialogRoute(builder: (context) => ConsumerHome(user: FirebaseAuth.instance.currentUser!.uid), context: context));
  }

  bool _isGujarati = true;

  void _showLanguageSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch Language'),
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

  void _showFilePickerCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(translate('Upload Documents')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(requiredDocuments.length, (index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(fileNames[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            fileUploaded[index]
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : const SizedBox.shrink(),
                            IconButton(
                              icon: const Icon(Icons.file_upload_outlined),
                              onPressed: () async {
                                await pickFile(index);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                }),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: selectedFiles.every((file) => file != null)
                      ? () {
                    Navigator.of(context).pop();
                    uploadFiles();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
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