import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _adminName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  // ✅ Load admin name from SharedPreferences
  Future<void> _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('userName') ?? "Admin";
    });
  }

  // ✅ Logout Function (Clears Session)
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        automaticallyImplyLeading: false, // Hide back button
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout, // ✅ Logout button
          ),
        ],
        backgroundColor: Colors.black,
      ),
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
                // 🏆 Admin Welcome
                Text(
                  "Welcome, $_adminName!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // 🔗 Manage Users
                _buildAdminButton(
                  context,
                  title: "Manage Users",
                  description: "View, edit, or remove users.",
                  onTap: () {
                    // Future: Implement User Management
                  },
                ),

                // 🔗 View Reports
                _buildAdminButton(
                  context,
                  title: "View Reports",
                  description: "Check system logs & reports.",
                  onTap: () {
                    // Future: Implement Reports Page
                  },
                ),

                // 🔗 Settings
                _buildAdminButton(
                  context,
                  title: "Settings",
                  description: "Modify admin settings.",
                  onTap: () {
                    // Future: Implement Settings Page
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📌 Admin Button Widget
  Widget _buildAdminButton(BuildContext context, {required String title, required String description, required VoidCallback onTap}) {
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
