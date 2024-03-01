import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  const AdditionalInfo(
      {super.key,
      required this.text,
      required this.icon,
      required this.status});

  final String text;
  final IconData icon;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 10),
          Text(text),
          const SizedBox(height: 10),
          Text(status),
        ],
      ),
    );
  }
}
