import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

import '../Database Operations/FarmerFinder.dart';

class ConsumersList extends StatefulWidget {
  const ConsumersList({super.key});

  @override
  State<ConsumersList> createState() => _ConsumersListState();
}

class _ConsumersListState extends State<ConsumersList>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> consumers;
  Map<String, dynamic>? selectedConsumer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    consumers = getConsumer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> deleteConsumer(String consumerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Consumers')
          .doc(consumerId)
          .delete();
      setState(() {
        consumers = getConsumer();
      });
    } catch (e) {
      print('Error deleting consumer: $e');
    }
  }

  void _showConsumerDetails(Map<String, dynamic> consumer) {
    setState(() {
      selectedConsumer = consumer;
    });
    _animationController.forward();
  }

  void _closeConsumerDetails() {
    _animationController.reverse().then((_) {
      setState(() {
        selectedConsumer = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Consumers List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: consumers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitWaveSpinner(color: Colors.green),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No Consumers Found",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                );
              } else {
                List<Map<String, dynamic>> users = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    String consumerId = user['id'] ?? "id";
                    return GestureDetector(
                      onTap: () => _showConsumerDetails(user),
                      child: Card(
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                radius: 30,
                                child: Text(
                                  '${user['firstName']?[0] ?? 'C'}${user['lastName']?[0] ?? 'N'}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user['firstName'] ?? 'First Name'} ${user['lastName'] ?? 'Last Name'}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_city,
                                            color: Colors.grey.shade700,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          user['city'] ?? 'Unknown',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            color: Colors.grey.shade700,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          user['phoneNumber'] ?? 'N/A',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red.shade400),
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                            'Are you sure you want to delete this consumer?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmDelete) {
                                    await deleteConsumer(consumerId);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          if (selectedConsumer != null)
            GestureDetector(
              onTap: _closeConsumerDetails,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Container(
                      color: Colors.black54,
                    ),
                  );
                },
              ),
            ),
          if (selectedConsumer != null)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: const EdgeInsets.all(24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedConsumer!['firstName'] ?? 'First Name'} ${selectedConsumer!['lastName'] ?? 'Last Name'}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _closeConsumerDetails,
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.green.shade200,
                          thickness: 1,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email_outlined,
                                color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedConsumer!['email'] ??
                                    'Email not available',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_city_outlined,
                                color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              selectedConsumer!['city'] ??
                                  'City not available',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              selectedConsumer!['phoneNumber'] ??
                                  'Phone number not available',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
