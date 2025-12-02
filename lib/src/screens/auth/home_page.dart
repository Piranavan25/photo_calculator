import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'scan_page.dart'; // make sure path is correct

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${user?.email ?? 'User'}",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              icon: Icon(Icons.camera_alt),
              label: Text("Scan Math Problem"),
            ),
          ],
        ),
      ),
    );
  }
}
