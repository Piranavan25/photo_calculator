import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signup() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Signup successful, navigate to Home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(20.0),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 50), // optional spacing
      TextField(
        controller: emailController,
        decoration: InputDecoration(labelText: "Email"),
      ),
      TextField(
        controller: passwordController,
        decoration: InputDecoration(labelText: "Password"),
        obscureText: true,
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: signup,
        child: Text("Sign Up"),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Text("Already have an account? Login"),
      ),
    ],
  ),
),

    );
  }
}
