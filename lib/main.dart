import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:my_music/views/home.dart';
import 'package:my_music/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      title: 'My Music',
      theme: ThemeData(
          fontFamily: "regular",
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          )),
    );
  }
}
