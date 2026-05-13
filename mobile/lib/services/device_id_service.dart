import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  final _storage = const FlutterSecureStorage();
  static const _key = 'device_id_hash';

  Future<String> getDeviceId() async {
    String? id = await _storage.read(key: _key);
    
    if (id == null) {
      // Create a unique ID for this installation
      final rawId = const Uuid().v4();
      // Hash it with a per-installation salt
      id = sha256.convert(utf8.encode(rawId)).toString();
      await _storage.write(key: _key, value: id);
    }
    
    return id;
  }
}
