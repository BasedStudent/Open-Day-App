import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // ✅ Save user session in SharedPreferences after signup
  Future<void> _saveUserSession(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', username);
  }

// ✅ Signup Function (Handles Username Already Taken)
Future<void> _signup() async {
  setState(() {
    _isLoading = true; // Show loading indicator
  });

  try {
    final response = await http.post(
      Uri.parse('http://192.168.50.201:8080/signup'), // ✅ Update with your server IP
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
        "email": _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      }),
    );

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    var responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      await _saveUserSession(_usernameController.text.trim()); // ✅ Store username

      // ✅ Redirect to Login Screen after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      String errorMessage = responseData['error'] ?? "Signup failed. Please try again.";
      _showErrorSnackbar(errorMessage);
    }
  } catch (e) {
    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    _showErrorSnackbar("Network error: Unable to connect to the server.");
  }
}

// ✅ Show Error Snackbar (Displays username error message)
void _showErrorSnackbar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // ✅ Dismiss keyboard on tap
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFC72C), Color(0xFF000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Welcome Text
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                Text(
                  "Sign up to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // 🔹 Username Input
                _buildTextField(
                  controller: _usernameController,
                  label: "Enter your username",
                  icon: Icons.person,
                ),

                SizedBox(height: 15),

                // 🔹 Password Input
                _buildTextField(
                  controller: _passwordController,
                  label: "Enter your password",
                  icon: Icons.lock,
                  obscureText: true,
                ),

                SizedBox(height: 15),

                // 🔹 Email Input (Optional)
                _buildTextField(
                  controller: _emailController,
                  label: "Enter your email (optional)",
                  icon: Icons.email,
                ),

                SizedBox(height: 30),

                // 🔹 Signup Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Color(0xFFFFC72C))
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFFC72C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(height: 20),

                // 🔹 Go to Login Page
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ),
                  child: Text(
                    "Already have an account? Log In",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📌 Custom TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
