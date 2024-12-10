import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat datang di Fourtify Weather!\n\n'
              'Kami menyediakan informasi cuaca harian yang sederhana, '
              'akurat, dan mudah digunakan untuk membantu Anda merencanakan aktivitas sehari-hari. '
              'Dengan tampilan yang ramah pengguna, Fourtify Weather menyajikan perkiraan cuaca '
              'lokal, suhu, kelembapan, serta kondisi angin secara real-time.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            const Text(
              'Fitur Utama:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Perkiraan Cuaca Real-Time: Dapatkan pembaruan terkini tentang cuaca di lokasi Anda.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Navigasi Mudah: Antarmuka intuitif yang dirancang untuk siapa saja.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Ringan dan Cepat: Hemat kuota dan berjalan lancar di berbagai perangkat.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
