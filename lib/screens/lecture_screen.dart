import 'package:flutter/material.dart';

class LectureScreen extends StatelessWidget {
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Logo at the top
              Image.asset('assets/images/logo.png', height: 120, width: 120),
              SizedBox(height: 20),

              // 🔹 Event Title
              Text(
                "Talk with Thomas Hartley",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // 🔹 Subtitle
              Text(
                "Join Thomas Hartley in the Lecture Hall for an insightful talk on technology and innovation.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // 🔹 Event Details
              _buildDetailBox(
                title: "🕒 Time",
                description: "11:00 AM - 12:30 PM",
              ),
              _buildDetailBox(
                title: "📍 Location",
                description: "Main Lecture Hall, Building A",
              ),
              _buildDetailBox(
                title: "🎤 Speaker",
                description: "Thomas Hartley - Technology Innovator",
              ),
              _buildDetailBox(
                title: "📜 Topic",
                description: "The Future of Artificial Intelligence",
              ),

              SizedBox(height: 30),

              // 🔹 Join Event Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Back to Overview",
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
    );
  }

  // 📌 Custom Detail Box Widget
  Widget _buildDetailBox({required String title, required String description}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFC72C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFC72C),
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
