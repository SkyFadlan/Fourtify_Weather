import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Result extends StatefulWidget {
  final String place; 

  const Result({super.key, required this.place});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  bool isFavorite = false; // Status favorit

  Future<Map<String, dynamic>> getDataFromAPI() async {
    final response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=${widget.place}&appid=de7678c04acc533e66e92fa9eb7ef787&units=metric&lang=id"));
    
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return data; 
    } else {
      throw Exception("Error!");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // Cek apakah tempat ini sudah ada di favorit
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.place);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favorites.remove(widget.place); // Hapus dari favorit
    } else {
      favorites.add(widget.place); // Tambah ke favorit
    }

    await prefs.setStringList('favorites', favorites);
    setState(() {
      isFavorite = !isFavorite; // Toggle status favorit
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hasil Pencarian", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 70),
          child: FutureBuilder(
            future: getDataFromAPI(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final data = snapshot.data!; // Non-nullable

                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(image: NetworkImage('https://flagsapi.com/${data["sys"]["country"]}/shiny/64.png')),
                      Text('${data["name"]}', style: const TextStyle(fontSize: 50)),
                      Text("${data["main"]["temp"]}°", style: const TextStyle(fontSize: 50)),
                      Text('${data["weather"][0]["description"]}', style: const TextStyle(fontSize: 30)),
                      Text('Kecepatan Angin: ${data["wind"]["speed"]} m/s', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                );
              } else {
                // Menampilkan ikon dan pesan "Tempat Tidak Diketahui" di tengah layar
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/pages/assets/error_page.png', // Pastikan ikon sudah disimpan di folder assets
                        width: 150, // Menentukan ukuran gambar
                        height: 150,
                      ),
                      const SizedBox(height: 20), // Memberi jarak antara ikon dan teks
                      const Text(
                        "Tempat Tidak Diketahui",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
