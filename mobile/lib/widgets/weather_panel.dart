import 'package:flutter/material.dart';

class WeatherPanel extends StatelessWidget {
  const WeatherPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloudy_snowing, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Local Rainfall Forecast',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  'Expected: 12mm in next 6h (High Risk)',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
