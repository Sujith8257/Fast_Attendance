import 'package:flutter/material.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0c0f14), // Background color
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    "NetMark",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Help button
                  GestureDetector(
                    onTap: () {
                      // Show help dialog or navigate to help screen
                    },
                    child: Icon(
                      Icons.help_outline,
                      color: Color(0xFFa0a6b1), // Text secondary
                      size: 24,
                    ),
                  ),
                ],
              ),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome text
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Login to continue your journey",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFa0a6b1), // Text secondary
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48),

                    // Login form
                    Column(
                      children: [
                        // Registration Number field
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFF1a1d22), // Surface color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _regNumberController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Registration Number",
                              hintStyle: TextStyle(
                                color: Color(0xFF6e7681), // Text placeholder
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Password field
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(0xFF1a1d22), // Surface color
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
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Color(0xFF6e7681), // Text placeholder
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Forgot password link
                        SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to forgot password screen
                              },
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFa0a6b1), // Text secondary
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer with login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0b79ee), // Primary color
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    // Handle login logic
                    if (_regNumberController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      // Navigate to student dashboard or handle login
                      Navigator.pushReplacementNamed(context, '/user');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    _regNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
