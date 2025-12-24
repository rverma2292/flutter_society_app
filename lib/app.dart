import 'package:flutter/material.dart';
import 'pages/menu_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society App',
      debugShowCheckedModeBanner: false,
      home: const MenuPage(),
    );
  }
}