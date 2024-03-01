import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_ui/widgets/additional_info.dart';
import 'package:weather_ui/widgets/hourly_weather.dart';
import 'package:weather_ui/services/get_weather_service.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  final Weather _weatherService = Weather();
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    // weather = _weatherService.getCurrentWeather(cityName: cityController.text);
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Call _getCurrentLocation() here
      final weatherData =
          await _weatherService.getCurrentWeather(); // Get async result
      setState(() {
        weather = Future.value(weatherData); // Update state with received data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              weather = _weatherService.getCurrentWeather(
                  cityName: cityController.text);
            });
          },
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 100,
              child: TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  hintText: 'City Name',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                onSubmitted: (String cityName) {
                  setState(() {
                    weather =
                        _weatherService.getCurrentWeather(cityName: cityName);
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final data = snapshot.data!;

              final currentWeatherData = data['list'][0];

              final currentTemp = currentWeatherData['main']['temp'];
              final currentSky = currentWeatherData['weather'][0]['main'];
              final currentPressure = currentWeatherData['main']['pressure'];
              final currentWindSpeed = currentWeatherData['wind']['speed'];
              final currentHumidity = currentWeatherData['main']['humidity'];

              final currentTempCelsius = currentTemp - 273.15;
              final formattedTempCelsius =
                  currentTempCelsius.toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${formattedTempCelsius} °C',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 65),
                                  const SizedBox(height: 10),
                                  Text(
                                    currentSky,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Hourly Forecast',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                          itemCount: 23,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky =
                                data['list'][index + 1]['weather'][0]['main'];
                            final hourlyTemp =
                                hourlyForecast['main']['temp'].toString();
                            final time =
                                DateTime.parse(hourlyForecast['dt_txt']);

                            final hourlyTempDouble = double.parse(hourlyTemp);

                            final currentTempCelsius =
                                hourlyTempDouble - 273.15;

                            final formattedTempCelsius =
                                currentTempCelsius.toStringAsFixed(0);

                            return HourlyWeather(
                              text: DateFormat.j().format(time),
                              status: formattedTempCelsius,
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                            );
                          }),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Additional Information',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfo(
                          text: 'Humidity',
                          icon: Icons.water_drop,
                          status: currentHumidity.toString(),
                        ),
                        AdditionalInfo(
                          text: 'Wind Speed',
                          icon: Icons.air,
                          status: currentWindSpeed.toString(),
                        ),
                        AdditionalInfo(
                          text: 'Pressure',
                          icon: Icons.beach_access,
                          status: currentPressure.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
