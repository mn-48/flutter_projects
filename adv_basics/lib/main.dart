// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adv_basics/start_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Color.fromARGB(255, 143, 58, 183)],
            ),
          ),
          child: const StartScreen(),
        ),
      ),
    ),
  );
}
