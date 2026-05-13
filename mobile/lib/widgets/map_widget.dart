import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import '../services/map_tile_service.dart';

import 'package:flutter_map_animations/flutter_map_animations.dart';
import '../models/report_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late final _mapController = AnimatedMapController(vsync: this);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController.mapController,
      options: const MapOptions(
        initialCenter: LatLng(0.0236, 37.9062), // Center of Kenya
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.floodmap.mobile',
          tileProvider: const FMTCStore(MapTileService.storeName).getTileProvider(),
        ),
        // Weather Risk Zone Overlay
        PolygonLayer(
          polygons: [
            Polygon(
              points: const [
                LatLng(2.8, 35.3),
                LatLng(3.5, 35.3),
                LatLng(3.5, 36.0),
                LatLng(2.8, 36.0),
              ],
              color: Colors.orange.withOpacity(0.3),
              isFilled: true,
              borderColor: Colors.orange,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        // Pulsing markers for verified reports
        const MarkerLayer(
          markers: [
            // Sample pulsing marker logic (simplified)
            Marker(
              point: LatLng(3.11, 35.6), // Lodwar, Turkana
              child: _MarkerWithPopup(),
            ),
          ],
        ),
      ],
    );
  }
}

class _MarkerWithPopup extends StatelessWidget {
  const _MarkerWithPopup();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verified Flood'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Category: Flooded'),
                Text('Depth: Knee Deep'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Send confirmation to backend
                  Navigator.pop(context);
                },
                child: const Text('I CONFIRM THIS'),
              ),
            ],
          ),
        );
      },
      child: const _PulsingMarker(),
    );
  }
}

class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker();

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.5 * (1 - _controller.value)),
            border: Border.all(
              color: Colors.red,
              width: 2 + (4 * _controller.value),
            ),
          ),
          child: const Center(
            child: Icon(Icons.warning, color: Colors.red, size: 12),
          ),
        );
      },
    );
  }
}
