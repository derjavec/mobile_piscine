import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String> getCityName(double latitude, double longitude) async {
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
          return "$city, $country";
        }
        return "City not found";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<List<Map<String, dynamic>>> searchCity(String pattern) async {
    final url =
        "https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(pattern)}&count=5&language=en&format=json";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List).map((city) {
          return {
            "description": "${city['name']}, ${city['country']}",
            "lat": city['latitude'],
            "lon": city['longitude'],
          };
        }).toList();
      }
    } catch (_) {}
    return [];
  }
}
