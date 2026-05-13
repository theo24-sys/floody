import 'package:latlong2/latlong.dart';

class WeatherService {
  // Mock rainfall forecast for Turkana
  Future<List<LatLngBounds>> getHighRiskZones() async {
    // In a real app, we'd fetch from a weather API (OpenWeatherMap, etc.)
    return [
      // Mock risk zone near Lodwar
      LatLngBounds(const LatLng(2.8, 35.3), const LatLng(3.5, 36.0)),
    ];
  }
}
