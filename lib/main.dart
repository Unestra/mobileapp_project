import 'package:flutter/material.dart';
import 'package:myapp/project.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line to initialize Flutter binding
  runApp(
    MaterialApp(
      home: FirstPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
