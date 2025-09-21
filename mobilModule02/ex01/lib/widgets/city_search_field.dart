import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/weather.dart';
import '../services/location.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CitySearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String city, double lat, double lon) onCitySelected;
  final VoidCallback onMyLocationPressed;

  const CitySearchField({
    super.key,
    required this.controller,
    required this.onCitySelected,
    required this.onMyLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      builder: (context, textController, focusNode) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Search city...",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: onMyLocationPressed,
            ),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return [];
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
        } catch (e) {
          print("Error en fetch: $e");
        }
        return [];
      },
      itemBuilder: (context, suggestion) {
        final s = suggestion;
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(s['description']),
        );
      },
      onSelected: (suggestion) {
        final s = suggestion;
        onCitySelected(s['description'], s['lat'], s['lon']);
      },
    );
  }
}
