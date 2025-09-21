import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'medium_weather_app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'medium_weather_app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _geolocalisation = '';
  String _weatherJson = '';
  String _city = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _setSearchText(String value){
    setState((){
       _geolocalisation = value;
    });
  }

Future<void> _getWeatherByCity(String city) async {
  final apiKey = '618026898d93f61e47fc1404911161a5';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _weatherJson = "${data['main']['temp']} °C";
      });
    } else if (response.statusCode == 404) {
      setState(() {
        _weatherJson = "City not found";
      });} else {
      setState(() {
        _weatherJson = "Error: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _weatherJson = "Error: $e";
    });
  }
}

Future<void> _getCoordinatesFromCity(String city) async {
  final apiKey = 'd2b71ba69d5b46ffaf42d4f00ef7279a';
  final url =
      'https://api.opencagedata.com/geocode/v1/json?q=$city&key=$apiKey&language=en';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['lat'];
        final lon = data['results'][0]['geometry']['lng'];

        setState(() {
          _geolocalisation += " Lat: $lat, Lon: $lon";
        });
      } else {
        setState(() {
          _geolocalisation += "";
        });
      }
    } else {
      setState(() {
        _geolocalisation += " Error: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _geolocalisation += " Error: $e";
    });
  }
}


Future<void> _getCityName(double latitude, double longitude) async {
  final apiKey = 'd2b71ba69d5b46ffaf42d4f00ef7279a';
  final url =
      'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$apiKey&language=en';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final components = data['results'][0]['components'];
        final city = components['city'] ??
            components['town'] ??
            components['village'] ??
            components['municipality'] ??
            'Unknown city';
        final country = components['country'] ?? 'Unknown country';

        setState(() {
          _geolocalisation = "$city, $country";
          _city = "$city";
        });
      } else {
        setState(() {
          _geolocalisation = "City not found";
        });
      }
    } else {
      setState(() {
        _geolocalisation = "Error: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _geolocalisation = "Error: $e";
    });
  }
}

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _geolocalisation = "Location services are disabled.";
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _geolocalisation = "Location permission denied.";
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _geolocalisation = "Location permission denied forever.";
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await _getCityName(position.latitude, position.longitude);
    if (_city.isNotEmpty)
      await _getWeatherByCity(_city);
    setState(() {
      _geolocalisation += " Lat: ${position.latitude}, Lon: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(

        backgroundColor: Colors.white,
        title: TextField(
          controller : _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location),
              onPressed: _getCurrentLocation,      
            ),
          ),
          onSubmitted: (value) async {
            _setSearchText(value);
            await _getCoordinatesFromCity(value);
            await _getWeatherByCity(value);
          }   
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/teletubis.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children:[
                          Text('Currently', 
                          style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                          const SizedBox(height: 10),
                          Text(
                            _geolocalisation,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          Text(
                            _weatherJson,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Text('Today',
                          style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                              _geolocalisation,
                              style: const TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          Text(
                            _weatherJson,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children:[
                          Text('Weekly',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,color: Colors.white),
                          ),
                          Text(
                                _geolocalisation,
                                style: const TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          Text(
                            _weatherJson,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
      ),        
    ),
          
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: 'Currently'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
          ],
          unselectedLabelColor: Colors.grey,
        ),
      ),
    );
  }
}
