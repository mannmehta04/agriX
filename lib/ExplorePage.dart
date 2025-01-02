import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final String apiUrl =
      'https://newsapi.org/v2/everything?q=agriculture&content=farming&apiKey=0a52a1b9f3374a0b8e5938e0cbd2ca57';
  final String plantCareApiUrl =
      // 'https://perenual.com/api/article-faq-list?key=sk-iL2V6715f3da0bfe07354&page=1';
      'https://perenual.com/api/article-faq-list?key=sk-prLE6715291fdd8737348&page=1';

  String selectedCategory = "Crop Tips"; // Default category set to "Crop Tips"

  Future<http.Client> createHttpClient() async {
    final ioc = new HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return IOClient(ioc);
  }

  Future<Map<String, dynamic>> fetchNewsData() async {
    http.Client client = await createHttpClient();

    final response = await client.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'PostmanRuntime/7.26.8',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load news data');
    }
  }

  Future<Map<String, dynamic>> fetchPlantCareData() async {
    http.Client client = await createHttpClient();

    final response = await client.get(
      Uri.parse(plantCareApiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load plant care data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          translate('Explore'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Main page margin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                categoryButton('Crop Tips'),
                SizedBox(width: 10),
                categoryButton('Latest News'),
              ],
            ),
            SizedBox(height: 16), // Spacing below category buttons
            Expanded(
              child: SingleChildScrollView(
                child: selectedCategory == 'Crop Tips'
                    ? buildPlantTipsSection()
                    : buildLatestNewsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryButton(String category) {
    bool isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green[600]!),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.greenAccent, blurRadius: 10)]
              : [BoxShadow(color: Colors.grey[300]!, blurRadius: 4)],
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.green[600],
          ),
        ),
      ),
    );
  }

  Widget buildLatestNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Center(
            child: Text(
              'Latest News',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: fetchNewsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SpinKitWaveSpinner(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No news data found.'));
            } else {
              var articles = snapshot.data!['articles'];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(articles.length, (index) {
                  var article = articles[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['urlToImage'] != null)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.0),
                              ),
                              child: Image.network(
                                article['urlToImage'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    child: Center(child: Text('Image not available')),
                                  );
                                },
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0), // Increased padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 18, // Increased font size
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6), // Increased spacing
                              Text(
                                article['description'] ?? 'No Description Available',
                                style: TextStyle(
                                  fontSize: 14, // Increased font size
                                  color: Colors.grey[600],
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildPlantTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Center(
            child: Text(
              'Plant Tips',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: fetchPlantCareData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SpinKitWaveSpinner(color: Colors.green));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No plant care data found.'));
            } else {
              var faqs = snapshot.data!['data'];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(faqs.length, (index) {
                  var faq = faqs[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (faq['default_image'] != null &&
                            faq['default_image']['regular_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                            child: Image.network(
                              faq['default_image']['regular_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Center(child: Text('Image not available')),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0), // Increased padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                faq['question'] ?? 'No Question',
                                style: const TextStyle(
                                  fontSize: 18, // Increased font size
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6), // Increased spacing
                              Text(
                                faq['answer'] ?? 'No Answer Available',
                                style: TextStyle(
                                  fontSize: 14, // Increased font size
                                  color: Colors.grey[600],
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }
          },
        ),
      ],
    );
  }
}
