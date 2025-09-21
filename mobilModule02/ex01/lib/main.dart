import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/weather.dart';
import '../services/location.dart';
import 'widgets/city_search_field.dart';
import 'widgets/weather_tabs.dart';

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
  List<String> _suggestions = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _getWeatherByCoordinates(double lat, double lon) async {
      final city = await LocationService.getCityName(lat, lon);
      final weather = await WeatherService.getWeatherByCoordinates(lat, lon);

      setState(() {
        _geolocalisation = city;
        _weatherJson = weather;
      });
    }

  Future<void> _getCurrentLocationAndWeather() async {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        try {
          final city = 
            await LocationService.getCityName(position.latitude, position.longitude);
          final weather =
            await WeatherService.getWeatherByCoordinates(position.latitude, position.longitude);
          setState(() {
          _geolocalisation = city;
          _weatherJson = weather;
          });
        }
        catch (e) {
          setState(() {
            _geolocalisation = "Error: $e";
            _weatherJson = "";
          });
      }
    }
    else {
      _geolocalisation = "Error, location not found";
      _weatherJson = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CitySearchField(
        controller: _searchController,
        onCitySelected: (cityDescription, lat, lon) async {
          setState(() {
            _geolocalisation = cityDescription;
          });
          await _getWeatherByCoordinates(lat, lon);
        },
        onMyLocationPressed: _getCurrentLocationAndWeather,
        ),
      ),

      body: WeatherTabs(
        controller: _tabController,
        geolocalisation: _geolocalisation,
        weatherJson: _weatherJson,
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
