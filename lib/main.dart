import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/event_overview_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Open Day App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthCheck(), // ✅ Start with AuthCheck to decide the first screen
    );
  }
}

// ✅ Checks if user is already logged in
class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  String? _username;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkUserSession(); // ✅ Check if user is logged in
  }

  // ✅ Check for saved login session
  Future<void> _checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('userName');
    String? role = prefs.getString('userRole');

    await Future.delayed(Duration(seconds: 1)); // Simulate loading time

    if (username != null) {
      // ✅ Redirect to Admin Dashboard if admin
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        // ✅ Redirect to Event Overview if normal user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventOverviewScreen(name: username)),
        );
      }
    } else {
      // ✅ If no user is logged in, show **Login Screen**
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Loading screen
    );
  }
}
