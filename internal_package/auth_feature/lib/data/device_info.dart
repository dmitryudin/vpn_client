import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

Future<Map<String, String>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceType = '';
  String deviceId = '';

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceType = 'android';

      deviceId = (await MobileDeviceIdentifier().getDeviceId()) ?? '';
      ;
      // '${androidInfo.manufacturer} ${androidInfo.brand} ${androidInfo.product} ${androidInfo.model} ${androidInfo..device}';
      print('device_id = $deviceId');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceType = 'ios';
      deviceId = iosInfo.identifierForVendor ?? '';
    }
  } catch (e) {
    print('Error getting device info: $e');
  }

  return {'deviceType': deviceType, 'deviceId': deviceId};
}
