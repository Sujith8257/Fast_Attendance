import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'config.dart';

class UploadCSVScreen extends StatefulWidget {
  const UploadCSVScreen({super.key});

  @override
  _UploadCSVScreenState createState() => _UploadCSVScreenState();
}

class _UploadCSVScreenState extends State<UploadCSVScreen> {
  String? _filePath;
  bool _isUploading = false;
  String _serverResponse = "";
  int _totalStudents = 0;
  int _presentStudents = 0;
  int _absentStudents = 0;
  Timer? _statsTimer;
  final _urlController = TextEditingController();
  String _registrationNumber = "";

  @override
  void initState() {
    super.initState();
    _fetchStats();
    // Refresh stats every 30 seconds
    // _statsTimer = Timer.periodic(Duration(seconds: 30), (timer) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.serverUrl}/attendance_stats'),
      );

      if (response.statusCode == 200) {
        final stats = json.decode(response.body);
        setState(() {
          _totalStudents = stats['total'];
          _presentStudents = stats['present'];
          _absentStudents = stats['absent'];
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

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
      Uri.parse('${Config.serverUrl}/upload_csv'),
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
      
      // Refresh stats after successful upload
      _fetchStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showServerUrlDialog() {
    _urlController.text = Config.serverUrl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://server-ip:port',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Example: http://10.2.8.97:5000',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Config.updateServerUrl(_urlController.text);
              Navigator.pop(context);
              _fetchStats(); // Refresh stats with new URL
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Server URL updated')),
              );
            },
            child: Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "KARE FAST · ADMIN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _showServerUrlDialog,
              tooltip: 'Configure Server URL',
            ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[100]!, Colors.grey[200]!],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Total",
                        count: _totalStudents,
                        color: Colors.blue,
                        icon: Icons.people,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/student_list',
                          arguments: {
                            'showPresent': false,
                            'showAbsent': false,
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: "Present",
                        count: _presentStudents,
                        color: Colors.green,
                        icon: Icons.check_circle,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/student_list',
                          arguments: {
                            'showPresent': true,
                            'showAbsent': false,
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: "Absent",
                        count: _absentStudents,
                        color: Colors.red,
                        icon: Icons.cancel,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/student_list',
                          arguments: {
                            'showPresent': false,
                            'showAbsent': true,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Upload Attendance Sheet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: pickFile,
                          icon: Icon(Icons.file_upload),
                          label: Text("Select CSV File", style: TextStyle(color: Colors.white),),
                        ),
                        if (_filePath != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Selected: ${_filePath!.split('/').last}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isUploading ? null : uploadFile,
                          icon: _isUploading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.cloud_upload),
                          label: Text(_isUploading ? "Uploading..." : "Upload", style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Manual Attendance Entry",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Enter Registration Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _registrationNumber = value;
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isUploading ? null : () => _uploadManualAttendance(),
                          child: Text("Mark Attendance"),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_serverResponse.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _serverResponse,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadManualAttendance() async {
    if (_registrationNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a registration number")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.serverUrl}/mark_attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'registrationNumber': _registrationNumber}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _serverResponse = jsonResponse['message'] ?? "Unknown response";
        });
        // Refresh student list after marking attendance
        // _fetchStudents();
      } else {
        setState(() {
          _serverResponse = "Failed to mark attendance";
        });
      }
    } catch (e) {
      setState(() {
        _serverResponse = "Error marking attendance";
      });
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _statsTimer?.cancel();
    super.dispose();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.1),
              ],
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 