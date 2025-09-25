import 'dart:convert';
import 'package:http/http.dart' as http;


class HourlyWeather {
    final DateTime time;
    final double temperature;
    final String description;
    final double windspeed;

    HourlyWeather({
      required this.time,
      required this.temperature,
      required this.description,
      required this.windspeed,
    });
  }

class DailyWeather {
    final DateTime date;
    final double minTemp;
    final double maxTemp;
    final String codes;

    DailyWeather({
      required this.date,
      required this.minTemp,
      required this.maxTemp,
      required this.codes,
    });
  }

class WeatherService {

  static String getWeatherDescription(int code) {
    if (code == 0) return "Clear sky";
    if (code == 1) return "Mainly clear";
    if (code == 2) return "Partly cloudy";
    if (code == 3) return "Overcast";
    if (code == 45 || code == 48) return "Fog";
    if ([51, 53, 55].contains(code)) return "Drizzle";
    if ([61, 63, 65].contains(code)) return "Rain";
    if ([71, 73, 75].contains(code)) return "Snowfall";
    if ([80, 81, 82].contains(code)) return "Rain showers";
    if (code == 95) return "Thunderstorm";
    return "Unknown";
  }

  static Future<String> getCurrentWeatherByCoordinates(double lat, double lon) async {

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final description = getWeatherDescription(current['weathercode']);
        return "${current['temperature']} °C, ${current['windspeed']} km/h, ${description}";
      } else {
        return("Error: ${response.statusCode}");
      }
    } catch (e) {
      return("Error: $e");      
    }
  }

  static Future<List<HourlyWeather>> getTodayWeatherByCoordinates(double lat, double lon) async {

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=48.08&longitude=7.28&hourly=temperature_2m,weathercode,windspeed_10m';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hourly = data['hourly'];

        final times = List<String>.from(hourly['time']);
        final temps = List<double>.from(hourly['temperature_2m'].map((e) => e.toDouble()));
        final codes = List<int>.from(hourly['weathercode']);
        final winds = List<double>.from(hourly['windspeed_10m'].map((e) => e.toDouble()));

        List<HourlyWeather> todayWeather = [];

        for (int i = 0; i < times.length; i++) {
          todayWeather.add(HourlyWeather(
            time: DateTime.parse(times[i]),
            temperature: temps[i],
            description: getWeatherDescription(codes[i]),
            windspeed: winds[i],
          ));
        }
        return todayWeather;
       } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  static Future<List<DailyWeather>> getWeeklyWeatherByCoordinates(double lat, double lon) async {

    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=48.08&longitude=7.28&daily=temperature_2m_max,temperature_2m_min,weathercode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];

        final date = List<String>.from(daily['time']);
        final minTemps = List<double>.from(daily['temperature_2m_min'].map((e) => e.toDouble()));
        final maxTemps = List<double>.from(daily['temperature_2m_max'].map((e) => e.toDouble()));
        final codes = List<int>.from(daily['weathercode']);

        List<DailyWeather> weeklyWeather = [];

        for (int i = 0; i < date.length; i++) {
          weeklyWeather.add(DailyWeather(
            date: DateTime.parse(date[i]),
            minTemp: minTemps[i],
            maxTemp: maxTemps[i],
            codes: getWeatherDescription(codes[i]),
          ));
        }
        return weeklyWeather;
        
       } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
