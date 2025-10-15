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
    // Refresh stats every 10 seconds for live updates
    _statsTimer =
        Timer.periodic(Duration(seconds: 10), (timer) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.serverUrl}/attendance_stats'),
      );

      if (response.statusCode == 200) {
        final stats = json.decode(response.body);
        setState(() {
          _totalStudents = stats['total'] ?? 0;
          _presentStudents = stats['present'] ?? 0;
          _absentStudents = stats['absent'] ?? 0;
        });
        print(
            '📊 Stats loaded - Total: $_totalStudents, Present: $_presentStudents, Absent: $_absentStudents');
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
        backgroundColor: Color(0xFF1f2937), // Dark background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Update Server URL',
          style: TextStyle(
            color: Color(0xFFf9fafb), // White text
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF374151), // Darker input background
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _urlController,
                style: TextStyle(
                  color: Color(0xFFf9fafb), // White text
                ),
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  labelStyle: TextStyle(
                    color: Color(0xFF9ca3af), // Gray label
                  ),
                  hintText: 'http://server-ip:port',
                  hintStyle: TextStyle(
                    color: Color(0xFF6b7280), // Darker gray hint
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Example: http://10.2.8.97:5000',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9ca3af), // Gray text
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFF9ca3af)), // Gray
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF818cf8), // Indigo
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Config.updateServerUrl(_urlController.text);
              Navigator.pop(context);
              _fetchStats(); // Refresh stats with new URL
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Server URL updated'),
                  backgroundColor: Color(0xFF10b981), // Green
                ),
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
    return Scaffold(
      backgroundColor:
          Color(0xFF111827), // Dark background like student dashboard
      appBar: AppBar(
        backgroundColor: Color(0xFF1f2937), // Dark app bar
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "KARE FAST · ADMIN",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color(0xFFf9fafb), // White text
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFd1d5db)),
            onPressed: _showServerUrlDialog,
            tooltip: 'Configure Server URL',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFd1d5db)),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics Cards with enhanced design
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1f2937),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Attendance Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFf9fafb),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: "Total",
                            count: _totalStudents,
                            color: Color(0xFF3b82f6), // Blue
                            icon: Icons.people_alt_rounded,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/admin',
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
                            color: Color(0xFF10b981), // Green
                            icon: Icons.check_circle_rounded,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/admin',
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
                            color: Color(0xFFef4444), // Red
                            icon: Icons.cancel_rounded,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/admin',
                              arguments: {
                                'showPresent': false,
                                'showAbsent': true,
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1f2937),
                      Color(0xFF111827),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3b82f6).withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFF3b82f6).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF3b82f6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.upload_file_rounded,
                              color: Color(0xFF3b82f6),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Upload Attendance Sheet",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFf9fafb),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF818cf8), // Indigo
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: pickFile,
                        icon: Icon(Icons.file_upload, color: Colors.white),
                        label: Text(
                          "Select CSV File",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_filePath != null)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF374151),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Selected: ${_filePath!.split('/').last}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF10b981), // Green
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF10b981), // Green
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isUploading ? null : uploadFile,
                        icon: _isUploading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.cloud_upload, color: Colors.white),
                        label: Text(
                          _isUploading ? "Uploading..." : "Upload",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1f2937),
                      Color(0xFF111827),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFef4444).withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFef4444).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFef4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_calendar_rounded,
                              color: Color(0xFFef4444),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Manual Attendance Entry",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFf9fafb),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF374151), // Darker input background
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: Color(0xFFf9fafb), // White text
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter Registration Number',
                            labelStyle: TextStyle(
                              color: Color(0xFF9ca3af), // Gray label
                            ),
                            hintText: 'e.g., 20K-0001',
                            hintStyle: TextStyle(
                              color: Color(0xFF6b7280), // Darker gray hint
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            _registrationNumber = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFef4444), // Red
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isUploading
                            ? null
                            : () => _uploadManualAttendance(),
                        child: Text(
                          "Mark Attendance",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_serverResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1f2937),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF10b981),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _serverResponse,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10b981), // Green
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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

  Future<void> _handleLogout() async {
    // Cancel the timer
    _statsTimer?.cancel();

    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1f2937), // Dark background
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFf9fafb), // White text
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Color(0xFFd1d5db), // Light gray text
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9ca3af)), // Gray
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFef4444), // Red
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _statsTimer?.cancel();
    super.dispose();
  }
}

class _StatCard extends StatefulWidget {
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
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF374151),
                  Color(0xFF1f2937),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onTap();
                },
                onTapDown: (_) {
                  setState(() => _isPressed = true);
                },
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                },
                onTapCancel: () {
                  setState(() => _isPressed = false);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9ca3af),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.count.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
