import 'package:flutter/material.dart';
import 'package:site_visit/screens/sitevisit_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Site Visit Demo',
      theme: ThemeData(
          primarySwatch: Colors.green,
      ),
      home: SiteVisit(),
    );
  }
}