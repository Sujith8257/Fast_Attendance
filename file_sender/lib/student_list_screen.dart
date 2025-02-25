import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'config.dart';

class StudentListScreen extends StatefulWidget {
  final bool showPresent;
  final bool showAbsent;

  const StudentListScreen({
    Key? key,
    this.showPresent = false,
    this.showAbsent = false,
  }) : super(key: key);

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  List<dynamic> _students = [];
  bool _isLoading = true;
  String _error = '';

  // List of colors for initials
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _logger.i('Initializing StudentListScreen');
    _logger.d('Show Present: ${widget.showPresent}, Show Absent: ${widget.showAbsent}');
    _fetchStudents();
  }

  Color _getColorForInitial(String initial) {
    return _colors[initial.codeUnitAt(0) % _colors.length];
  }

  Future<void> _fetchStudents() async {
    _logger.i('Fetching students list');
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.serverUrl}/students'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.d('Received ${data['students'].length} students from server');
        
        // Log the raw student data for debugging
        _logger.d('Raw student data: ${data['students']}');

        setState(() {
          _students = data['students'].where((student) {
            _logger.d('Checking student: ${student['name']} - Present: ${student['isPresent']}');
            if (widget.showPresent) return student['isPresent'] == true;
            if (widget.showAbsent) return student['isPresent'] == false;
            return true;
          }).toList();
        });
        
        _logger.i('Filtered to ${_students.length} students based on present/absent criteria');
      } else {
        _logger.e('Failed to load students', error: response.body);
        setState(() {
          _error = 'Failed to load students';
        });
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching students', error: e, stackTrace: stackTrace);
      setState(() {
        _error = 'Connection error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchStudents(String query) async {
    if (query.isEmpty) {
      _logger.d('Empty search query, fetching all students');
      _fetchStudents();
      return;
    }

    _logger.i('Searching students with query: $query');
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.serverUrl}/search_students/$query'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.d('Received ${data['students'].length} students from search');
        
        // Log the raw student data for debugging
        _logger.d('Raw search student data: ${data['students']}');

        setState(() {
          _students = data['students'].where((student) {
            _logger.d('Checking student: ${student['name']} - Present: ${student['isPresent']}');
            if (widget.showPresent) return student['isPresent'] == true;
            if (widget.showAbsent) return student['isPresent'] == false;
            return true;
          }).toList();
        });
        
        _logger.i('Filtered to ${_students.length} students after search');
      } else {
        _logger.e('Search failed', error: response.body);
        setState(() {
          _error = 'Search failed';
        });
      }
    } catch (e, stackTrace) {
      _logger.e('Error during search', error: e, stackTrace: stackTrace);
      setState(() {
        _error = 'Connection error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "All Students";
    if (widget.showPresent) title = "Present Students";
    if (widget.showAbsent) title = "Absent Students";

    _logger.d('Building StudentListScreen with title: $title');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _logger.d('Back button pressed');
            Navigator.pop(context);
          },
        ),
        title: Text(
          "KARE FAST · $title",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or registration number',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _searchStudents,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Text(
                            _error,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : _students.isEmpty
                          ? Center(
                              child: Text('No students found'),
                            )
                          : ListView.builder(
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getColorForInitial(
                                        student['initial'],
                                      ),
                                      child: Text(
                                        student['initial'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      student['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      student['registrationNumber'],
                                    ),
                                    trailing: Icon(
                                      student['isPresent']
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: student['isPresent']
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logger.d('Disposing StudentListScreen');
    _searchController.dispose();
    super.dispose();
  }
} 