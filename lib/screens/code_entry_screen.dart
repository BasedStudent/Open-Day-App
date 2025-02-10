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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: "Enter Session Code",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _joinChat,
                child: Text("Join Chat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
