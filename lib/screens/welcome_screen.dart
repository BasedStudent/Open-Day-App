import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_overview_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // ✅ Load saved user info when screen opens
  }

  // ✅ Load saved user info from SharedPreferences
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('userName');
    String? savedEmail = prefs.getString('userEmail');

    if (savedName != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventOverviewScreen(name: savedName),
        ),
      );
    }

    setState(() {
      _nameController.text = savedName ?? "";
      _emailController.text = savedEmail ?? "";
      _isLoading = false;
    });
  }

  // ✅ Save user info locally
  Future<void> _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
  }

  // ✅ Proceed to the main screen
  void _navigateToEventOverview(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await _saveUserInfo(); // ✅ Save user info before navigating
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventOverviewScreen(name: name),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Please enter your name to continue."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // ✅ Dismiss keyboard on tap
      child: Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator()) // ✅ Show loading indicator
            : Container(
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
                      // Welcome Text
                      Text(
                        "Welcome to the Open Day!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),

                      // Instruction Text
                      Text(
                        "Enter your details to continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),

                      // Name Input Field
                      _buildTextField(
                        controller: _nameController,
                        label: "Enter your name",
                        icon: Icons.person,
                        autoFocus: true, // ✅ Auto-focus for better UX
                      ),

                      SizedBox(height: 15),

                      // Email Input Field (Optional)
                      _buildTextField(
                        controller: _emailController,
                        label: "Enter your email (optional)",
                        icon: Icons.email,
                      ),

                      SizedBox(height: 30),

                      // Continue Button
                      ElevatedButton(
                        onPressed: () => _navigateToEventOverview(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFFC72C),
                            fontWeight: FontWeight.bold,
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

  // Custom TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool autoFocus = false,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      autofocus: autoFocus,
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
