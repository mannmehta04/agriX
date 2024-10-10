import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Updatedetails extends StatefulWidget {
  final Map<String, dynamic> consumer;
  const Updatedetails({super.key,required this.consumer});

  @override
  State<Updatedetails> createState() => _UpdatedetailsState();
}

class _UpdatedetailsState extends State<Updatedetails> {
  void _updateField(String field, String currentValue) async {
    String? newValue = await _showUpdateDialog(field, currentValue);
    if (newValue != null && newValue.isNotEmpty) {
      // Updating the local state
      setState(() {
        widget.consumer[field] = newValue;
      });

      // Extracting consumer ID
      String consumerId = widget.consumer['id'];

      // Update the Firestore document
      try {
        await FirebaseFirestore.instance
            .collection('Consumers') // Ensure collection name matches in Firestore
            .doc(consumerId) // Document ID of the consumer
            .update({field: widget.consumer[field]});

        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field updated successfully!')),
        );
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $field: $e')),
        );
      }
    }
  }

  Future<String?> _showUpdateDialog(String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update $field'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = widget.consumer['firstName'] ?? 'No First Name';
    final String lastName = widget.consumer['lastName'] ?? 'No Last Name';
    final String city = widget.consumer['city'] ?? 'No City';
    final String phoneNumber = widget.consumer['phoneNumber'] ?? 'No Phone Number';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Consumer Details',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'First Name: $firstName',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateField('firstName', firstName),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Name: $lastName',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateField('lastName', lastName),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'City: $city',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateField('city', city),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phone Number: $phoneNumber',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateField('phoneNumber', phoneNumber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
