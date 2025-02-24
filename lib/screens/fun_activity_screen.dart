import 'package:flutter/material.dart';

class FunActivityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFC72C), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ✅ Scrollable Content to Prevent Overflow Issues
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 Logo Image
                  Image.asset('assets/images/logo.png', height: 100, width: 100),
                  SizedBox(height: 20),

                  // 🔹 Page Title
                  Text(
                    "Fun Activity Event",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),

                  Text(
                    "Join us in the Square for exciting activities and games!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // ✅ Fun Activities List
                  _buildActivityCard(
                    title: "Treasure Hunt",
                    description: "Find clues hidden around campus and win prizes!",
                    icon: Icons.map,
                  ),

                  _buildActivityCard(
                    title: "Obstacle Course",
                    description: "Compete in a fun obstacle course challenge!",
                    icon: Icons.sports,
                  ),

                  _buildActivityCard(
                    title: "Live Music & Dance",
                    description: "Enjoy live performances by students and guests.",
                    icon: Icons.music_note,
                  ),

                  SizedBox(height: 20),

                  // 🔙 Back Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Back To Overview",
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
        ],
      ),
    );
  }

  // 📌 Activity Card Widget
  Widget _buildActivityCard({required String title, required String description, required IconData icon}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFFC72C), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFFC72C), size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}
