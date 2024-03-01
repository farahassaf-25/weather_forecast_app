import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';

class Weather {
  Future<Map<String, dynamic>> getCurrentWeather({String? cityName}) async {
    try {
      String apiKey = '4af409a4c67493e64a7c44c96d9c51e3';

      if (cityName == null || cityName.isEmpty) {
        // Get user's current location
        Position position = await _getCurrentLocation();
        double latitude = position.latitude;
        double longitude = position.longitude;

        final res = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&APPID=$apiKey'));

        final data = jsonDecode(res.body);

        if (data['cod'] != '200') {
          throw 'An unexpected error occurred';
        }
        return data;
      } else {
        // Weather for a specified city
        final res = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey'));

        final data = jsonDecode(res.body);

        if (data['cod'] != '200') {
          throw 'An unexpected error occurred';
        }
        return data;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Position> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      throw 'Unable to get current location: $e';
    }
  }
}
