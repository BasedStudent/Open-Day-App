import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/event_overview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedName = prefs.getString('userName');

  runApp(MyApp(savedName: savedName));
}

class MyApp extends StatelessWidget {
  final String? savedName;

  MyApp({required this.savedName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: savedName != null ? EventOverviewScreen(name: savedName!) : WelcomeScreen(),
    );
  }
}
