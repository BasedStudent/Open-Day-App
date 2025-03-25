import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profanity_filter/profanity_filter.dart';
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
  final ProfanityFilter _filter = ProfanityFilter();
  String userName = "Anonymous";
  DateTime? timeoutUntil;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Anonymous";
    });
    await _checkTimeoutStatus();
  }

  Future<void> _checkTimeoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final timeoutMillis = prefs.getInt('timeoutUntil');
    if (timeoutMillis != null) {
      final savedTime = DateTime.fromMillisecondsSinceEpoch(timeoutMillis);
      if (DateTime.now().isBefore(savedTime)) {
        setState(() {
          timeoutUntil = savedTime;
        });
      } else {
        setState(() {
          timeoutUntil = null;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    if (timeoutUntil != null && now.isBefore(timeoutUntil!)) {
      final secondsLeft = timeoutUntil!.difference(now).inSeconds;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You're muted for another $secondsLeft seconds."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_filter.hasProfanity(text)) {
      final prefs = await SharedPreferences.getInstance();
      final newTimeout = now.add(Duration(seconds: 60));
      await prefs.setInt('timeoutUntil', newTimeout.millisecondsSinceEpoch);
      setState(() {
        timeoutUntil = newTimeout;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inappropriate language detected. Muted for 60 seconds."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .collection('messages')
        .add({
      'user': userName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
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
                stream: FirebaseFirestore.instance
                    .collection('sessions')
                    .doc(widget.sessionCode)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
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

            // 🔹 Navigation Buttons
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
