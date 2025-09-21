import 'package:flutter/material.dart';

class WeatherTabs extends StatelessWidget{
    final TabController controller;
    final String geolocalisation;
    final String weatherJson;

    const WeatherTabs({
        super.key,
        required this.controller,
        required this.geolocalisation,
        required this.weatherJson,
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
                    _buildTab('Currently'),
                    _buildTab('Today'),
                    _buildTab('Weekly'),
                ],
                ),
            ),
            ],
        ),
        );
    }

    Widget _buildTab(String title) {
        return Align(
        alignment: Alignment.topCenter,
        child: Column(
            children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text(
                geolocalisation,
                style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
                weatherJson,
                style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            ],
        ),
        );
    }
}
