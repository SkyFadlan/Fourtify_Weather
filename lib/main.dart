import 'package:flutter/material.dart';
import 'package:latihan_flutter/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(), // Mengarahkan ke HomePage sebagai halaman awal
      debugShowCheckedModeBanner: false, // Menonaktifkan banner debug
    );
  }
}
