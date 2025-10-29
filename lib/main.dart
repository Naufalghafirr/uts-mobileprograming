import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const AkademikApp());
}

class AkademikApp extends StatelessWidget {
  const AkademikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Informasi Akademik',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
