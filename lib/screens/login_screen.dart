import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_overview_screen.dart';
import 'admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ Login Function (Authenticates user via API)
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final response = await http.post(
      Uri.parse('http://192.168.50.201:8080/login'), // ✅ Replace with your actual server IP
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', data['username']);
      await prefs.setString('userRole', data['role']); // ✅ Save user role

      // ✅ Redirect Admin to Admin Dashboard
      if (data['role'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        // ✅ Redirect User to Event Overview
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventOverviewScreen(name: data['username'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${json.decode(response.body)['error']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Login as Anonymous
  Future<void> _loginAsAnonymous() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.50.201:8080/anonymous-login'), // ✅ Replace with your actual server IP
      headers: {"Content-Type": "application/json"},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', data['username']);
      await prefs.setString('userRole', "anonymous"); // ✅ Save role

      // ✅ Redirect Anonymous User to Event Overview
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EventOverviewScreen(name: data['username'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anonymous login failed: ${json.decode(response.body)['error']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              Text(
                "Please login to continue",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // 🔹 Username Field
              _buildTextField(
                controller: _usernameController,
                label: "Enter your username",
                icon: Icons.person,
              ),
              SizedBox(height: 15),

              // 🔹 Password Field
              _buildTextField(
                controller: _passwordController,
                label: "Enter your password",
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 30),

              // 🔹 Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFC72C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 20),

              // 🔹 Login as Anonymous Button
              ElevatedButton(
                onPressed: _isLoading ? null : _loginAsAnonymous,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Login as Anonymous",
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFFFFC72C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 20),

              // 🔹 Go to Signup Page
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                ),
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Custom TextField Widget
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
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
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFC72C), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
