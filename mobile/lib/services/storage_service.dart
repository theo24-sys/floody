import 'package:hive_flutter/hive_flutter.dart';
import '../models/report_model.dart';

class StorageService {
  static const String boxName = 'flood_reports';
  static const String cacheBoxName = 'api_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReportModelAdapter());
    }
    await Hive.openBox<ReportModel>(boxName);
    await Hive.openBox(cacheBoxName);
  }

  Future<void> cacheVerifiedReports(Map<String, dynamic> geojson) async {
    final box = Hive.box(cacheBoxName);
    await box.put('verified_reports', geojson);
  }

  Map<String, dynamic>? getCachedVerifiedReports() {
    final box = Hive.box(cacheBoxName);
    return box.get('verified_reports');
  }

  Future<void> saveReport(ReportModel report) async {
    final box = Hive.box<ReportModel>(boxName);
    await box.add(report);
  }

  List<ReportModel> getQueuedReports() {
    final box = Hive.box<ReportModel>(boxName);
    return box.values.toList();
  }

  Future<void> removeReport(int index) async {
    final box = Hive.box<ReportModel>(boxName);
    await box.deleteAt(index);
  }
}
