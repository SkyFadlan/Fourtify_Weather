import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihan_flutter/pages/result.dart';
import 'package:latihan_flutter/pages/setting.dart';
import 'package:latihan_flutter/pages/favorite.dart';
import 'package:latihan_flutter/pages/home.dart';

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController placeController = TextEditingController();
  int _selectedIndex = 1; // Set default index ke 1 (Search)
  List<Map<String, String>> searchHistory = [];

  @override
  void initState() {
    super.initState();
    loadSearchHistory();
  }

  // Memuat data histori dari SharedPreferences
  Future<void> loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList('searchHistory') ?? [];

    setState(() {
      searchHistory = historyList.map((e) {
        List<String> details = e.split('|');
        return {
          'city': details[0],
          'tempHigh': details[1],
          'tempLow': details[2],
        };
      }).toList();
    });
  }

  // Menambahkan data ke histori dan menyimpannya di SharedPreferences
  Future<void> addSearchHistory(String city, String tempHigh, String tempLow) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    searchHistory.insert(0, {
      'city': city,
      'tempHigh': tempHigh,
      'tempLow': tempLow,
    });

    List<String> historyList = searchHistory.map((e) {
      return '${e['city']}|${e['tempHigh']}|${e['tempLow']}';
    }).toList();

    await prefs.setStringList('searchHistory', historyList);

    setState(() {}); // Refresh UI
  }

  // Menghapus item dari histori dan memperbarui SharedPreferences
  Future<void> removeFromHistory(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    searchHistory.removeAt(index);

    List<String> historyList = searchHistory.map((e) {
      return '${e['city']}|${e['tempHigh']}|${e['tempLow']}';
    }).toList();

    await prefs.setStringList('searchHistory', historyList);

    setState(() {}); // Refresh UI
  }

  void onSearch() {
    String city = placeController.text.trim();
    if (city.isNotEmpty) {
      // Simulasi data suhu tinggi dan rendah untuk contoh
      String tempHigh = '20';
      String tempLow = '13';
      addSearchHistory(city, tempHigh, tempLow);
      
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Result(place: city);
      }));
    }
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
      // Tetap di halaman pencarian
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Cari Daerah atau Kota',
              icon: Icon(Icons.search, color: Colors.grey),
            ),
            controller: placeController,
            onSubmitted: (_) => onSearch(),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: onSearch,
              child: const Text("Cari"),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'History Pencarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: searchHistory.length,
                itemBuilder: (context, index) {
                  final item = searchHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['city'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        Text(
                          '${item['tempHigh']} / ${item['tempLow']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeFromHistory(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
