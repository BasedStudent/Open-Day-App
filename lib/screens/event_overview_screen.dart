import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'placeholder_screen.dart';
import 'code_entry_screen.dart';
import 'dart:async'; // ✅ Import for Timer

class EventOverviewScreen extends StatefulWidget {
  final String name;

  const EventOverviewScreen({Key? key, required this.name}) : super(key: key);

  @override
  _EventOverviewScreenState createState() => _EventOverviewScreenState();
}

class _EventOverviewScreenState extends State<EventOverviewScreen> {
  bool _showWelcomeMessage = true;

  @override
  void initState() {
    super.initState();

    // ✅ Hide "Welcome, *username*" after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcomeMessage = false;
        });
      }
    });
  }

  // ✅ Open Google Maps
  void _openGoogleMaps() async {
    final Uri googleMapsUrl = Uri.parse("https://maps.app.goo.gl/i9TdwMD5nMuHsiB36");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }

  // ✅ Logout and clear session
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears user session

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ❌ Disable the back button
      child: Scaffold(
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

            // ✅ Scrollable Content (Fix Overflow Issue)
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // 🔹 Logo Image (Added Here - Slightly Smaller)
                    Image.asset('assets/images/logo.png', height: 100, width: 100),
                    SizedBox(height: 20),

                    // 🏆 Title
                    Text(
                      "Activities Throughout the Day",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // 🎯 Event Buttons
                    _buildEventButton(
                      context,
                      title: "Talk with Thomas Hartley",
                      description: "Join Thomas Hartley in the Lecture Hall for an insightful talk.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceholderScreen(title: "Talk with Thomas Hartley"),
                          ),
                        );
                      },
                    ),

                    _buildEventButton(
                      context,
                      title: "Guided Tour Around the University",
                      description: "Explore the campus with our guided tour on Google Maps.",
                      onTap: _openGoogleMaps, // ✅ Opens Google Maps externally
                    ),

                    _buildEventButton(
                      context,
                      title: "Fun Activity Event",
                      description: "Join us in the Square for fun activities!",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceholderScreen(title: "Fun Activity Event"),
                          ),
                        );
                      },
                    ),

                    // 🔴 NEW: Join Live Chat
                    _buildEventButton(
                      context,
                      title: "Join Live Chat",
                      description: "Enter a session code to chat with others.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CodeEntryScreen()),
                        );
                      },
                    ),

                    SizedBox(height: 20),

                    // 🔗 Logout Button
                    ElevatedButton(
                      onPressed: () => _logout(context), // ✅ Logout clears session
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Logout",
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

            // ✅ Centered Overlay Box for "Welcome, *username*!"
            if (_showWelcomeMessage)
              AnimatedOpacity(
                opacity: _showWelcomeMessage ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7), // ✅ Dark semi-transparent overlay
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Welcome, ${widget.name}!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 📌 Event Button Widget
  Widget _buildEventButton(BuildContext context, {required String title, required String description, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}
