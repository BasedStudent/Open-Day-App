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

   // 🔹 PLACE HELPER HERE 👇
  String _capitalizeName(String name) {
    if (name.isEmpty) return "";
    return name[0].toUpperCase() + name.substring(1);
  }


  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Anonymous";
    });
  }

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

  Future<void> _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _editMessage(String messageId, String currentText) async {
    final TextEditingController _editController =
        TextEditingController(text: currentText);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text("Edit Message", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _editController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Update your message",
            hintStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black26,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final updatedText = _editController.text.trim();
              if (updatedText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('sessions')
                    .doc(widget.sessionCode)
                    .collection('messages')
                    .doc(messageId)
                    .update({'text': updatedText});
              }
              Navigator.pop(context);
            },
            child: Text("Save", style: TextStyle(color: Color(0xFFFFC72C))),
          ),
        ],
      ),
    );
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
            SizedBox(height: 40),
            Text(
              "Live Chat - ${widget.sessionCode}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

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
                      final sender = messageData['user'];
                      final text = messageData['text'];
                      final isMine = sender == userName;
                      final messageId = messageData.id;

                      return _buildMessageBubble(sender, text, isMine, messageId);
                    },
                  );
                },
              ),
            ),

            // 🔹 Message Input
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
                      MaterialPageRoute(
                          builder: (context) => EventOverviewScreen(name: userName)),
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

  // 📌 Navigation Button
  Widget _buildNavButton(String title, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // 📌 Message Bubble with Edit/Delete
  Widget _buildMessageBubble(String sender, String message, bool isMine, String messageId) {
  return Align(
    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMine ? Color(0xFFFFC72C) : Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.start : CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeName(sender),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isMine ? Colors.black : Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMine ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Action icons (Edit/Delete)
          if (isMine) ...[
            SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 25, color: isMine ? Colors.black : Colors.white),
                  onPressed: () => _editMessage(messageId, message),
                  tooltip: "Edit",
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 25, color: isMine ? Colors.black : Colors.white),
                  onPressed: () => _deleteMessage(messageId),
                  tooltip: "Delete",
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}


}