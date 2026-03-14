import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class LicenseService {
  static const String _baseUrl = 'https://crediblemark.com/api/public/verify-license';
  static const String _productSlug = 'warung-madura-store-checker';

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      return 'web_${webBrowserInfo.browserName.name}_${webBrowserInfo.userAgent?.hashCode}';
    }

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique ID on Android
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.deviceId;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.machineId ?? 'unknown_linux';
    } else if (Platform.isMacOS) {
      final macosInfo = await deviceInfo.macOsInfo;
      return macosInfo.systemGUID ?? 'unknown_macos';
    }
    return 'unknown_device';
  }

  static Future<bool> verifyLicense(String key) async {
    try {
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'key': key,
          'productSlug': _productSlug,
          'machineId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
