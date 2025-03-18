import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'code_entry_screen.dart';
import 'event_overview_screen.dart';

class ChatScreen extends StatefulWidget {
  final String sessionCode;

  const ChatScreen({Key? key, required this.sessionCode}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String userName = "Anonymous";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Load the username from SharedPreferences
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Anonymous";
    });
  }

  // Send a message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionCode)
          .collection('messages')
          .add({
        'user': userName,
        'text': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
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
        child: Column(
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                "Live Chat - ${widget.sessionCode}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 🔹 Chat Messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Text(doc['text']);
                    }).toList(),
                  );
                },
              ),
            ),

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true, // Show newest messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var messageData = messages[index];

                      return _buildMessageBubble(
                        messageData['user'],
                        messageData['text'],
                        messageData['user'] == userName,
                      );
                    },
                  );
                },
              ),
            ),

            // 🔹 Message Input Field
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: Colors.black.withOpacity(0.9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFFFFC72C)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),

            // 🔹 Navigation Buttons (Placed at Bottom)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton("Back to Code Entry", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CodeEntryScreen()),
                    );
                  }),
                  _buildNavButton("Back to Overview", () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EventOverviewScreen(name: userName)),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 Styled Navigation Button
  Widget _buildNavButton(String title, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFFFFC72C),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 📌 Styled Message Bubble
  Widget _buildMessageBubble(String sender, String message, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? Color(0xFFFFC72C) : Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
