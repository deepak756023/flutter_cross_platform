import 'package:flutter/material.dart';
import 'package:password_credentials_sqflite/authentication/auth_page.dart';
import 'package:password_credentials_sqflite/myhome_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(248, 92, 4, 243),
        ),
      ),
      home: const AuthPage(),
    );
  }
}
