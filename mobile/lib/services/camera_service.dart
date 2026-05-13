import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCompressImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Initial quality reduction
    );

    if (image == null) return null;

    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "temp_${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 10, // Extreme compression for Turkana (low data)
      minWidth: 800,
      minHeight: 600,
    );

    if (result == null) return null;
    
    return File(result.path);
  }
}
