import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latihan_flutter/pages/home.dart';
import 'package:latihan_flutter/pages/search_field.dart';
import 'package:latihan_flutter/pages/setting.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _selectedIndex = 2;
  List<String> favoritePlaces = [];
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritePlaces = prefs.getStringList('favorites') ?? [];
    });

    for (String place in favoritePlaces) {
      await _fetchWeatherData(place);
    }
  }

  Future<void> _fetchWeatherData(String city) async {
    final apiKey = 'de7678c04acc533e66e92fa9eb7ef787'; // Ganti dengan API key OpenWeatherMap Anda
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData[city] = {
            'temperature': data['main']['temp'].toStringAsFixed(0),
            'description': data['weather'][0]['description'],
            'tempMin': data['main']['temp_min'].toStringAsFixed(0),
            'tempMax': data['main']['temp_max'].toStringAsFixed(0),
          };
        });
      }
    } catch (e) {
      print("Error fetching weather data: $e");
    }
  }

  Future<void> _removeFromFavorites(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritePlaces.remove(city);
      weatherData.remove(city);
    });
    await prefs.setStringList('favorites', favoritePlaces);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SearchField()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke halaman pencarian (SearchField)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchField()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: favoritePlaces.isEmpty
          ? const Center(
              child: Text('Tidak ada tempat favorit.', style: TextStyle(fontSize: 24)),
            )
          : ListView.builder(
              itemCount: favoritePlaces.length,
              itemBuilder: (context, index) {
                final city = favoritePlaces[index];
                final weather = weatherData[city];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weather != null ? weather['description'] : 'Loading...',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              weather != null ? '${weather['temperature']}°' : '--°',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weather != null
                                  ? '${weather['tempMin']}°/${weather['tempMax']}°'
                                  : '--/--°',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeFromFavorites(city);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10.0,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
