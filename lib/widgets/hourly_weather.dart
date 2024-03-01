import 'package:flutter/material.dart';

class HourlyWeather extends StatelessWidget {
  const HourlyWeather(
      {super.key,
      required this.text,
      required this.icon,
      required this.status});

  final String text;
  final IconData icon;
  final String status;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Icon(icon, size: 30),
              const SizedBox(height: 10),
              Text(status),
            ],
          ),
        ),
      ),
    );
  }
}
