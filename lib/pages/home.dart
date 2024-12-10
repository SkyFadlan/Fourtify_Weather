import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:latihan_flutter/pages/favorite.dart';
import 'package:latihan_flutter/pages/search_field.dart';
import 'package:latihan_flutter/pages/setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Untuk navigasi tab bawah
  Map<String, dynamic>? _weatherData; // Data cuaca saat ini
  List<Map<String, dynamic>> _hourlyForecast = []; // Data cuaca per jam
  List<Map<String, dynamic>> _fullHourlyForecast = []; // Semua data perkiraan
  String _selectedDate =
      DateFormat('MMM d, yyyy').format(DateTime.now()); // Tanggal yang dipilih

  // Fungsi untuk mengambil data cuaca
  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=bogor&appid=de7678c04acc533e66e92fa9eb7ef787&units=metric&lang=id'));

      final forecastResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=bogor&appid=de7678c04acc533e66e92fa9eb7ef787&units=metric&lang=id'));

      if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);

          // Ambil data perkiraan per jam
          List<dynamic> forecastList =
              json.decode(forecastResponse.body)['list'];

          // Simpan semua data perkiraan per jam
          _fullHourlyForecast = forecastList
              .map((entry) => entry as Map<String, dynamic>)
              .toList();

          // Filter data untuk tanggal yang dipilih
          _filterHourlyForecast(_selectedDate);
        });
      } else {
        // Tampilkan pesan kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan data cuaca')),
        );
      }
    } catch (e) {
      // Tampilkan pesan error jika jaringan bermasalah
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  // Fungsi untuk menghitung tanggal berikutnya
  List<String> getUpcomingDates() {
    return List.generate(4, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return DateFormat('MMM d, yyyy').format(date);
    });
  }

  // Inisialisasi data cuaca
  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  // Navigasi tab bawah
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
  // Filter data cuaca berdasarkan tanggal
  void _filterHourlyForecast(String selectedDate) {
    final filteredForecast = _fullHourlyForecast.where((entry) {
      final date = DateFormat('MMM d, yyyy')
          .format(DateTime.parse(entry['dt_txt']));
      return date == selectedDate;
    }).toList();

    setState(() {
      _hourlyForecast = filteredForecast;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final String currentTime = DateFormat('h:mm a').format(DateTime.now());

    final String temperature = _weatherData?['main']['temp']?.toString() ?? '';
    final String description =
        _weatherData?['weather']?[0]['description'] ?? '';
    final String windSpeed = _weatherData?['wind']['speed']?.toString() ?? '';
    final String humidity = _weatherData?['main']['humidity']?.toString() ?? '';
    final String iconCode = _weatherData?['weather']?[0]['icon'] ?? '01d';
    final String iconUrl =
        'https://openweathermap.org/img/wn/$iconCode@2x.png';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _weatherData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          // Bagian dropdown tanggal dan waktu
                          Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                DropdownButton<String>(
                                  value: _selectedDate,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(
                                      color: Colors.blueAccent, fontSize: 16),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.blueAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      _selectedDate = newValue;
                                      _filterHourlyForecast(newValue);
                                    }
                                  },
                                  items: getUpcomingDates()
                                      .map<DropdownMenuItem<String>>(
                                          (String date) {
                                    return DropdownMenuItem<String>(
                                      value: date,
                                      child: Text(date),
                                    );
                                  }).toList(),
                                ),
                                Text(
                                  currentTime,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Lokasi
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Bogor, Indonesia',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Ikon cuaca
                          Center(
                            child: SizedBox(
                              width: 250,
                              height: 240,
                              child: Image.network(
                                iconUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Informasi utama
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[100],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _selectedDate,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$temperature°',
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(Icons.air,
                                            color: Colors.grey[600]),
                                        const Text(
                                          'Angin',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          '$windSpeed km/h',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Icon(Icons.water_drop,
                                            color: Colors.grey[600]),
                                        const Text(
                                          'Kelembaban',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          '$humidity %',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Perkiraan per jam
                    if (_hourlyForecast.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _hourlyForecast.length,
                          itemBuilder: (context, index) {
                            final hourData = _hourlyForecast[index];
                            final hourTemp =
                                hourData['main']['temp'].toString();
                            final hourWeather =
                                hourData['weather'][0]['description'];
                            final hourIcon = hourData['weather'][0]['icon'];
                            final hourIconUrl =
                                'https://openweathermap.org/img/wn/$hourIcon@2x.png';
                            final hourTime = DateFormat('HH:mm').format(
                                DateTime.parse(hourData['dt_txt']));

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Text(hourTime,
                                      style: const TextStyle(fontSize: 16)),
                                  Image.network(
                                      hourIconUrl, width: 40, height: 40),
                                  Text('$hourTemp°',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text(hourWeather,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
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
