import 'package:flutter/material.dart';
import 'package:my_music/views/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMyHomePage(context); // Pass context here
  }

  _navigateToMyHomePage(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(), // Navigate to MyHomePage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/peakpx.jpg'), // Change the path to your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/Music  Lab.png',
            width: 350,
            height: 350,
          ),
        ),
      ),
    );
  }
}
