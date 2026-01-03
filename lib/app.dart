import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/login_page.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MenuPage() : const LoginPage(),
    );
  }
}