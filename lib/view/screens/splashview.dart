import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/view/screens/home_screen.dart';
import 'package:login/view/screens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';


class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted.
      print("Location permission is granted");
    } else {
      // Permission denied.
      print("Location permission is denied");
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // user not logged ==> Login Screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false);
      } else {
        // user already logged in ==> Home Screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (route) => false);
      }
      requestLocationPermission();
    });
  }
  @override
  Widget build(BuildContext context) {
      // ignore: prefer_const_constructors
    return Scaffold(
      backgroundColor: Color(0xFF1E319D),
      body: Center(
        child: 
        Image.asset('assets/images/logo.png'),
      ),
    );
  }
}
