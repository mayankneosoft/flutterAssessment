import 'dart:async';
import 'package:flutter/material.dart';
import 'jokes_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyFinalHomeApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final imagewidth = screenwidth * 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex:5,
            child: Container(
              child: Image.asset(
                'assets/splashbg.jpg',
                fit: BoxFit.fill,
                width: imagewidth,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: const [
                Text(
                  'Jokes it!',
                  style: TextStyle(
                    fontSize: 60,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'your daily dose',
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                     fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



