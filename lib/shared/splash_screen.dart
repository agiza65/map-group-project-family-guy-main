import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'package:Care_Plus/screens/login/login_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required Null Function() onFinished}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after delay
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // or your brand color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/profile_avatar.png',
              width: 290,
              height: 230,
            ),
            const SizedBox(height: 30),
            SpinKitFadingCircle(color: Colors.green.shade700, size: 50.0),
            const SizedBox(height: 20),
            Text(
              "L o a d i n g . . .",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
