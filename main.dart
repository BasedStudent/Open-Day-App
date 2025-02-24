import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/event_overview_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: AuthCheck(), // ✅ Handles authentication logic
    );
  }
}

// ✅ AuthCheck determines which screen to show at startup
class AuthCheck extends StatelessWidget {
  Future<Map<String, String?>> _getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('userName'),
      'role': prefs.getString('userRole'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String? username = snapshot.data!['username'];
        String? role = snapshot.data!['role'];

        if (username != null) {
          if (role == 'admin') {
            return AdminDashboardScreen(); // ✅ Show admin panel
          } else {
            return EventOverviewScreen(name: username); // ✅ Show event overview
          }
        }

        return LoginScreen(); // ✅ Show login screen if not authenticated
      },
    );
  }
}
