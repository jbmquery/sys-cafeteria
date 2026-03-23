import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cafetería App',
      home: const LoginPage(),
    );
  }
}
