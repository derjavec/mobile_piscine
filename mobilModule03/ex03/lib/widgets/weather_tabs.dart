import 'package:flutter/material.dart';
import '../services/weather.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherTabs extends StatelessWidget {
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

  Widget buildTemperatureChart(List<HourlyWeather> hourlyWeather) {
    if (hourlyWeather.isEmpty) {
    return const Center(
      child: Text(
        "No data",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
    double minTemp = hourlyWeather.map((w) => w.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = hourlyWeather.map((w) => w.temperature).reduce((a, b) => a > b ? a : b);
    double step = 1; 
    List<double> yValues = [];
    for (double t = minTemp.floorToDouble(); t <= maxTemp.ceilToDouble(); t += step) {
    yValues.add(t);
    }
    return LineChart(
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= hourlyWeather.length) {
                  return const SizedBox();
                }
                final hour =
                    hourlyWeather[index].time.hour.toString();
                final minute = hourlyWeather[index].time.minute.toString().padLeft(2, '0');
                return Text("$hour:$minute",
                    style: const TextStyle(color: Colors.white, fontSize: 12));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (!yValues.contains(value)) return const SizedBox();
                return Text(
                  '${value.toInt()}°',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              hourlyWeather.length,
              (i) => FlSpot(i.toDouble(), hourlyWeather[i].temperature),
            ),
            isCurved: true,
            color: Colors.orangeAccent,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orangeAccent.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  String getBackgroundGif(String weather) {
    final w = weather.toLowerCase();
    if (w.contains("rain")) return "assets/gifs/rainy.gif";
    if (w.contains("cloud") || w.contains("overcast")) {
      return "assets/gifs/cloudy.gif";
    }
    if (w.contains("sun") || w.contains("clear")) {
      return "assets/gifs/sunny.gif";
    }
    if (w.contains("storm")) return "assets/gifs/tornado.gif";
    return "assets/teletubis.jpeg";
  }

  String getWeatherIcon(String weather) {
    final w = weather.toLowerCase();
    if (w.contains("rain")) return "assets/icons/rainy.png";
    if (w.contains("cloud") || w.contains("overcast")) {
      return "assets/icons/cloudy.png";
    }
    if (w.contains("sun") || w.contains("clear")) {
      return "assets/icons/sunny.png";
    }
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

  Widget _buildTab(String title, dynamic weather) {
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
            if (weather != null && weather is String)
              Text(
                weather,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            if (weather != null && weather is List<HourlyWeather>)
                Expanded(
                    child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                        children: [
                        SizedBox(
                            height: 200,
                            child: buildTemperatureChart(weather.cast<HourlyWeather>()),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                            child: ListView.builder(
                            itemCount: weather.length,
                            itemBuilder: (context, index) {
                                final w = weather[index] as HourlyWeather;
                                return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Center(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min, // ajusta al contenido
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                        Image.asset(
                                            getWeatherIcon(w.description),
                                            width: 40,
                                            height: 40,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                            "${w.time.hour}:${w.time.minute.toString().padLeft(2, '0')} - ${w.temperature}°C",
                                            style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                            "${w.description}, ${w.windspeed} km/h",
                                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                        ],
                                    ),
                                    ),
                                );
                            },
                            ),
                        ),
                        ],
                    ),
                    ),
                ),

            if (weather != null && weather is List<DailyWeather>)
              Expanded(
                child: ListView.builder(
                  itemCount: weather.length,
                  itemBuilder: (context, index) {
                    final w = weather[index];
                    return Center(
                      child: Text(
                        "${w.date.toLocal().toString().split(' ')[0]} - ${w.codes}, ${w.minTemp}°C - ${w.maxTemp}°C",
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
