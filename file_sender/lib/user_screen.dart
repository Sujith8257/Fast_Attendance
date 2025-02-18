import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _uniqueIdController = TextEditingController();
  String _userName = "";
  String _uniqueIdResponse = "";

  Future<void> fetchUserDetails(String uniqueId) async {
    final response = await http.get(
      Uri.parse('http://10.2.8.97:5000/get_user/$uniqueId'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _userName = jsonResponse['Name'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User found: ${jsonResponse['Name']}")),
      );
    } else {
      final jsonResponse = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['error'] ?? "Error fetching user")),
      );
    }
  }

  Future<void> uploadUniqueId(String uniqueId) async {
    final response = await http.post(
      Uri.parse('http://10.2.8.97:5000/upload_unique_id/$uniqueId'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _uniqueIdResponse = jsonResponse['message'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'])),
      );
    } else {
      final jsonResponse = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['error'] ?? "Error uploading ID")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _uniqueIdController,
              decoration: InputDecoration(
                labelText: "Enter Registration Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchUserDetails(_uniqueIdController.text.trim());
              },
              child: Text("Fetch User Details"),
            ),
            ElevatedButton(
              onPressed: () {
                uploadUniqueId(_uniqueIdController.text.trim());
              },
              child: Text("Upload Unique ID"),
            ),
            if (_userName.isNotEmpty)
              Text(
                "User Name: $_userName",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (_uniqueIdResponse.isNotEmpty)
              Text(
                "Response: $_uniqueIdResponse",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
} 