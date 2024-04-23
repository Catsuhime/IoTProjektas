import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'trainer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TrainerApp());
}

class TrainerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => TrainerHomeScreen(),
      },
    );
  }
}
