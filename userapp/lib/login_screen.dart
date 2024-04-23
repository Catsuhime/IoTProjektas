//login_screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
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
          ElevatedButton(
            onPressed: () => loginUser(context),
            child: Text("Login"),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text("Register"),
          ),
        ],
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login Failed')));
    }
  }
}
