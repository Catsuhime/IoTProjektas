import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController trainerCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register as Trainer")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: trainerCodeController,
              decoration: InputDecoration(labelText: "Trainer Code"),
            ),
            ElevatedButton(
              onPressed: () => registerUser(context),
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    if (trainerCodeController.text != "1234") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid trainer code")));
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration Failed')));
    }
  }
}
