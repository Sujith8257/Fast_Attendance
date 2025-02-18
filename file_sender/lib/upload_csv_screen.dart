import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadCSVScreen extends StatefulWidget {
  @override
  _UploadCSVScreenState createState() => _UploadCSVScreenState();
}

class _UploadCSVScreenState extends State<UploadCSVScreen> {
  String? _filePath;
  bool _isUploading = false;
  String _serverResponse = "";

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a CSV file first")),
      );
      return;
    }

    setState(() => _isUploading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.2.8.97:5000/upload_csv'), // Change this to your Flask server IP
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', _filePath!),
    );

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      setState(() {
        _serverResponse = jsonResponse['message'] ?? "Unknown response";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'])),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload CSV")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: Text("Select CSV File"),
            ),
            if (_filePath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Selected: ${_filePath!.split('/').last}"),
              ),
            SizedBox(height: 10),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadFile,
                    child: Text("Upload"),
                  ),
            SizedBox(height: 20),
            if (_serverResponse.isNotEmpty)
              Text(
                "Server Response: $_serverResponse",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
} 