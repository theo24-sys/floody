import 'package:dio/dio.dart';
import '../models/report_model.dart';

class UploadService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://YOUR_BACKEND_URL/api/', // Replace with real URL
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<bool> uploadReport(ReportModel report) async {
    try {
      dynamic data;
      if (report.imagePath != null) {
        data = FormData.fromMap({
          ...report.toJson(),
          'image': await MultipartFile.fromFile(report.imagePath!),
        });
      } else {
        data = report.toJson();
      }

      final response = await _dio.post(
        'report/',
        data: data,
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Upload failed: $e');
      return false;
    }
  }
}
