import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {

  static Future<String> getWeatherByCoordinates(double lat, double lon) async {

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));
    
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        return "${current['temperature']} °C";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
