import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FacultySignup extends StatefulWidget {
  const FacultySignup({super.key});

  @override
  _FacultySignupState createState() => _FacultySignupState();
}

class _FacultySignupState extends State<FacultySignup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<Map<String, dynamic>> _classSections = [
    {
      'csvFile': null,
      'sectionName': '',
      'controller': TextEditingController(),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121416), // Background color
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      "Create Faculty Account",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Spacer to balance the layout
                  SizedBox(width: 40),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 32),

                    // Name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFF2c3035), // Secondary color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your full name",
                              hintStyle: TextStyle(
                                color: Color(0xFFa2abb3), // Text secondary
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Staff ID field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Staff ID",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFF2c3035), // Secondary color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _staffIdController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "e.g., F12345",
                              hintStyle: TextStyle(
                                color: Color(0xFFa2abb3), // Text secondary
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Class sections
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class Sections",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        ..._classSections
                            .map((section) => _buildClassSection(section))
                            ,
                        SizedBox(height: 16),
                        // Add more sections button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _classSections.add({
                                'csvFile': null,
                                'sectionName': '',
                                'controller': TextEditingController(),
                              });
                            });
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFF2c3035), // Secondary color
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Color(0xFFdce7f3), // Primary color
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Set Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFF2c3035), // Secondary color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Create a strong password",
                              hintStyle: TextStyle(
                                color: Color(0xFFa2abb3), // Text secondary
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32), // Extra space at bottom for scrolling
                  ],
                ),
              ),
            ),

            // Footer with signup button
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFdce7f3), // Primary color
                        foregroundColor: Color(0xFF121416), // Background color
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        // Handle signup logic
                        if (_nameController.text.isNotEmpty &&
                            _staffIdController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          // Navigate to faculty dashboard or handle signup
                          Navigator.pushReplacementNamed(context, '/admin');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFa2abb3), // Text secondary
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFdce7f3), // Primary color
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSection(Map<String, dynamic> section) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Labels row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Upload Class CSV",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  "Section Name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16),
              SizedBox(width: 56), // Space for remove button
            ],
          ),
          SizedBox(height: 8),
          // Input fields row
          Row(
            children: [
              // CSV Upload
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['csv'],
                    );
                    if (result != null) {
                      setState(() {
                        section['csvFile'] = result.files.first;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xFF2c3035), // Secondary color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              section['csvFile']?.name ?? "Upload file",
                              style: TextStyle(
                                color: section['csvFile'] != null
                                    ? Colors.white
                                    : Color(0xFFa2abb3), // Text secondary
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.upload,
                            color: Color(0xFFa2abb3), // Text secondary
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Section Name
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF2c3035), // Secondary color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: section['controller'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g., Sec A",
                      hintStyle: TextStyle(
                        color: Color(0xFFa2abb3), // Text secondary
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Remove button
              GestureDetector(
                onTap: () {
                  if (_classSections.length > 1) {
                    setState(() {
                      _classSections.remove(section);
                    });
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF2c3035), // Secondary color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Color(0xFFdce7f3), // Primary color
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _staffIdController.dispose();
    _passwordController.dispose();
    for (var section in _classSections) {
      section['controller'].dispose();
    }
    super.dispose();
  }
}
