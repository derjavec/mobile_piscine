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
    @override
    Widget build(BuildContext context) {
        return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
            image: AssetImage("assets/teletubis.jpeg"),
            fit: BoxFit.cover,
            ),
        ),
        child: Column(
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
                        style: const TextStyle(fontSize: 24, color: Colors.white),
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
