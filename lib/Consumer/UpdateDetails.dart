import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Updatedetails extends StatefulWidget {
  final Map<String, dynamic> consumer;
  const Updatedetails({super.key, required this.consumer});

  @override
  State<Updatedetails> createState() => _UpdatedetailsState();
}

class _UpdatedetailsState extends State<Updatedetails> {
  void _updateField(String field, String currentValue) async {
    String? newValue = await _showUpdateDialog(field, currentValue);
    if (newValue != null && newValue.isNotEmpty) {
      setState(() {
        widget.consumer[field] = newValue;
      });

      String consumerId = widget.consumer['id'];

      try {
        await FirebaseFirestore.instance
            .collection('Consumers')
            .doc(consumerId)
            .update({field: widget.consumer[field]});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showUpdateDialog(String field, String currentValue) {
    TextEditingController controller =
    TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Update $field',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate('Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(translate('Update')),
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
    final String phoneNumber =
        widget.consumer['phoneNumber'] ?? 'No Phone Number';

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text(
          translate('Consumer Details'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(translate('First Name'), firstName),
                _buildDetailRow(translate('Last Name'), lastName),
                _buildDetailRow(translate('City'), city),
                _buildDetailRow(translate('Phone Number'), phoneNumber),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.green,
            ),
            onPressed: () => _updateField(label.toLowerCase(), value),
          ),
        ],
      ),
    );
  }
}