import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

class MapTileService {
  static const String storeName = 'flood_zones';

  Future<void> init() async {
    await FMTCObjectBoxBackend().initialise();
    final store = const FMTCStore(storeName);
    await store.manage.create();
  }

  Future<void> downloadCounties() async {
    final store = const FMTCStore(storeName);
    
    final regions = [
      // Turkana
      LatLngBounds(const LatLng(2.5, 34.5), const LatLng(5.5, 36.5)),
      // Tana River
      LatLngBounds(const LatLng(-2.5, 39.5), const LatLng(0.5, 41.5)),
      // Budalangi
      LatLngBounds(const LatLng(0.0, 33.9), const LatLng(0.8, 34.5)),
    ];

    for (final bounds in regions) {
      final region = bounds.toRegion(
        minZoom: 10,
        maxZoom: 16,
      );
      
      // In a real app, we'd use store.download.start() and listen to progress
      // For now, we just define the logic
      print('Starting download for region: $bounds');
    }
  }
}
