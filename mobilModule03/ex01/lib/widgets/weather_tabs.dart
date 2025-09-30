import 'package:flutter/material.dart';
import '../services/weather.dart';

class WeatherTabs extends StatelessWidget{
    final TabController controller;
    final String geolocalisation;
    final String currentWeather;
    final List<HourlyWeather> todayWeather;
    final List<DailyWeather> weeklyWeather;

    const WeatherTabs({
        super.key,
        required this.controller,
        required this.geolocalisation,
        required this.currentWeather,
        required this.todayWeather,
        required this.weeklyWeather,
    });
    
    String getBackgroundGif(String weather) {
        final w = weather.toLowerCase();
        if (w.contains("rain")) return "assets/gifs/rainy.gif";
        if (w.contains("cloud") || w.contains("overcast")) return "assets/gifs/cloudy.gif";
        if (w.contains("sun") || w.contains("clear")) return "assets/gifs/sunny.gif";
        if (w.contains("storm")) return "assets/gifs/tornado.gif";
        return "assets/teletubis.jpeg";
        }
    
    String getWeatherIcon(String weather) {
        final w = weather.toLowerCase();
        if (w.contains("rain")) return "assets/icons/rainy.png";
        if (w.contains("cloud") || w.contains("overcast")) return "assets/icons/cloudy.png";
        if (w.contains("sun") || w.contains("clear")) return "assets/icons/sunny.png";
        if (w.contains("storm")) return "assets/icons/tornado.png";
        return "assets/icons/sunny.png";
        }

    @override
    Widget build(BuildContext context) {
        return Stack(
            children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                        image: AssetImage(getBackgroundGif(currentWeather)),
                        fit: BoxFit.cover,
                        ),
                    ),
                ),
                Positioned(
                    top: 20,
                    right: 20,
                    child: Image.asset(
                        getWeatherIcon(currentWeather),
                        width: 80,
                        height: 80,
                    ),
                ),
                Column(
                    children: [
                    Expanded(
                        child: TabBarView(
                        controller: controller,
                        children: [
                            _buildTab('Currently', currentWeather),
                            _buildTab('Today', todayWeather),
                            _buildTab('Weekly', weeklyWeather),
                        ],
                        ),
                    ),
                    ],
                ),
            ],
        
        );
    }

    Widget _buildTab(String title, weather) {
        return Align(
        alignment: Alignment.topCenter,
        child: Container(
            decoration: BoxDecoration(
            color: (weather is List) 
            ? Colors.black.withOpacity(0.5)
            : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(
                        geolocalisation,
                        style: TextStyle(
                            color: geolocalisation.startsWith("Error")
                                ? Colors.red
                                : Colors.white,
                            fontWeight: geolocalisation.startsWith("Error")
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 20,
                        ),
                    ),
                    const SizedBox(height: 10),
                    if (weather is String)
                        Text(
                            weather,
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                    
                    if (weather is List)
                        Expanded(
                            child: ListView.builder(
                                itemCount: weather.length,
                                itemBuilder: (context, index) {
                                    final w = weather[index];
                                    if (w is HourlyWeather) 
                                        return Center(
                                            child: Text(
                                            "${w.time.hour.toString().padLeft(2,'0')}:${w.time.minute.toString().padLeft(2,'0')} - ${w.temperature}°C, ${w.description}, ${w.windspeed} km/h",
                                            style: const TextStyle(fontSize: 20, color: Colors.white),
                                            ),
                                        );
                                    
                                    if (w is DailyWeather) 
                                        return Center(
                                            child: Text(
                                                "${w.date.toLocal().toString().split(' ')[0]} - ${w.codes}, ${w.minTemp}°C - ${w.maxTemp}°C",
                                                style: const TextStyle(fontSize: 20, color: Colors.white),
                                            ),
                                        );
                                    
                                    return const SizedBox();
                                },
                            ),
                        ),          
                ],
            ),
        )
        );
    }
}
