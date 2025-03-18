import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_overview_screen.dart';
import 'admin_dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ Login Function
  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://72.167.35.123:8080/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['username']);
        await prefs.setString('userRole', data['role']);

        if (data['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EventOverviewScreen(name: data['username'])),
          );
        }
      } else {
        _showError("Login failed: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Network error: Unable to connect to the server.");
    }
  }

  // ✅ Login as Anonymous
  Future<void> _loginAsAnonymous() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://72.167.35.123:8080/anonymous-login'),
        headers: {"Content-Type": "application/json"},
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['username']);
        await prefs.setString('userRole', "anonymous");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventOverviewScreen(name: data['username'])),
        );
      } else {
        _showError("Anonymous login failed: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Network error: Unable to connect to the server.");
    }
  }

  // ✅ Show Error Message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Close keyboard when tapping outside
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
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
                    children: [
                      _buildTextField(controller: _usernameController, label: "Username", icon: Icons.person),
                      _buildTextField(controller: _passwordController, label: "Password", icon: Icons.lock, obscureText: true),
                      SizedBox(height: 30),
                      ElevatedButton(onPressed: _login, child: Text("Log In")),
                    ],
                  

                      // 🔹 Logo Image
                      Image.asset('assets/images/logo.png', height: 150, width: 150),
                      SizedBox(height: 30),

                      // 🔹 Welcome Text
                      Text(
                        "Welcome Back!",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please login to continue",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
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
                                style: TextStyle(fontSize: 18, color: Color(0xFFFFC72C), fontWeight: FontWeight.bold),
                              ),
                      ),
                      SizedBox(height: 20),

                      // 🔹 Login as Anonymous Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loginAsAnonymous,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Login as Anonymous",
                                style: TextStyle(fontSize: 18, color: Color(0xFFFFC72C), fontWeight: FontWeight.bold),
                              ),
                      ),
                      SizedBox(height: 20),

                      // 🔹 Go to Signup Page
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        ),
                        child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
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
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFC72C), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
