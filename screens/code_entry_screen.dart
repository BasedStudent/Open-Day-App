import 'package:flutter/material.dart';
import 'chat_screen.dart';

class CodeEntryScreen extends StatefulWidget {
  @override
  _CodeEntryScreenState createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _joinChat() {
    if (_codeController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(sessionCode: _codeController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Session Code")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC72C), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TextField for session code with no border and better style
                _buildTextField(
                  controller: _codeController,
                  label: "Enter Session Code",
                  icon: Icons.lock,
                ),
                SizedBox(height: 20),
                // Join Chat Button
                ElevatedButton(
                  onPressed: _joinChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Join Chat",
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

  // 📌 Custom TextField Widget without the border
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        enabledBorder: InputBorder.none, // No border
        focusedBorder: InputBorder.none, // No border when focused
      ),
    );
  }
}
