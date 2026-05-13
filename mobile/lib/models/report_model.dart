import 'package:hive/hive.dart';

part 'report_model.g.dart';

@HiveType(typeId: 0)
class ReportModel extends HiveObject {
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final double lat;

  @HiveField(2)
  final double lng;

  @HiveField(3)
  final String category;

  @HiveField(6)
  final String? severity;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? imagePath;

  ReportModel({
    required this.deviceId,
    required this.lat,
    required this.lng,
    required this.category,
    required this.timestamp,
    this.severity,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'lat': lat,
        'lng': lng,
        'category': category,
        if (severity != null) 'severity': severity,
        'timestamp': timestamp.toIso8601String(),
        if (imagePath != null) 'image': imagePath,
      };
}
