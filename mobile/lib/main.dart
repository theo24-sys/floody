import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'services/upload_service.dart';
import 'models/report_model.dart';
import 'services/location_service.dart';
import 'services/device_id_service.dart';
import 'services/camera_service.dart';
import 'services/map_tile_service.dart';
import 'widgets/map_widget.dart';
import 'widgets/weather_panel.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status_codes;

const String uploadTask = "com.floodmap.uploadTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final storageService = StorageService();
    await storageService.init();
    final uploadService = UploadService();
    
    final reports = storageService.getQueuedReports();
    for (int i = 0; i < reports.length; i++) {
      final success = await uploadService.uploadReport(reports[i]);
      if (success) {
        await storageService.removeReport(i);
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();

  final mapTileService = MapTileService();
  await mapTileService.init();
  
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(const ProviderScope(child: FloodMapApp()));
}

class FloodMapApp extends StatelessWidget {
  const FloodMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloodMap-K',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('sw'),
      ],
      home: const HomeScreen(),
    );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final LocationService _locationService = LocationService();
  final DeviceIdService _deviceIdService = DeviceIdService();
  final CameraService _cameraService = CameraService();
  
  bool _isReporting = false;
  String? _capturedImagePath;
  String _selectedSeverity = 'ankle';

  Future<void> _capturePhoto() async {
    final file = await _cameraService.pickAndCompressImage();
    if (file != null) {
      setState(() {
        _capturedImagePath = file.path;
      });
    }
  }

  Future<void> _handleReport() async {
    setState(() {
      _isReporting = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final deviceId = await _deviceIdService.getDeviceId();
      
      final report = ReportModel(
        deviceId: deviceId,
        lat: position.latitude,
        lng: position.longitude,
        category: "flooded",
        severity: _selectedSeverity,
        timestamp: DateTime.now(),
        imagePath: _capturedImagePath,
      );

      final storageService = StorageService();
      await storageService.saveReport(report);
      
      Workmanager().registerOneOffTask(
        "1",
        uploadTask,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      setState(() {
        _capturedImagePath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved and queued for upload!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isReporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.get('title')),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.report_problem), text: l10n.get('report_tab')),
              Tab(icon: const Icon(Icons.map), text: l10n.get('map_tab')),
            ],
          ),
          actions: [
            // Simple language toggle for the demo
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                // TODO: Implement stateful language switching
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Report Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const WeatherPanel(),
                    const SizedBox(height: 20),
                    const Text(
                      'RURAL KENYA FLOOD REPORTING',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text('Water Depth:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: ['ankle', 'knee', 'waist', 'above'].map((s) {
                        return ChoiceChip(
                          label: Text(s.toUpperCase()),
                          selected: _selectedSeverity == s,
                          onSelected: (val) {
                            if (val) setState(() => _selectedSeverity = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (_capturedImagePath != null)
                      Container(
                        height: 150,
                        width: 150,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_capturedImagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => setState(() => _capturedImagePath = null),
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _capturePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_capturedImagePath == null 
                        ? l10n.get('add_photo') 
                        : l10n.get('change_photo')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isReporting ? null : _handleReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isReporting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(l10n.get('button'), style: const TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
              ),
            ),
            // Map Tab
            const MapWidget(),
          ],
        ),
      ),
    );
  }
}
