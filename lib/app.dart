import 'package:flutter/material.dart';
import 'src/screens/auth/login_page.dart';
import 'src/screens/auth/signup.dart';
import 'src/screens/auth/home_page.dart';
import 'src/screens/auth/scan_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/scan': (context) => const ScanPage(),

      },
    );
  }
}
