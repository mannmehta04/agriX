import 'package:agrix/Consumer/CategoryView.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Categorysearch extends StatefulWidget {
  const Categorysearch({super.key});

  @override
  State<Categorysearch> createState() => _CategorysearchState();
}

class _CategorysearchState extends State<Categorysearch> {
  final List<String> category = [
    translate('Fruit'),
    translate('Vegetable'),
    translate('Leafy Greens'),
    translate('Root Vegetables'),
    translate('Herbs'),
    translate('Grains'),
    translate('Legumes'),
    translate('Berries'),
    translate('Tubers'),
    translate('Nuts'),
    translate('Mushrooms')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          translate('Category'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
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
                        itemCount: category.length,
                        itemBuilder: (context, index) {
                          return _buildGridButton(category[index], Icons.category, Colors.blue[100], () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Categoryview(category: category[index])));
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
