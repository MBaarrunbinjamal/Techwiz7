import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class permisions {
  Future<void> getnotificationpermision() async {
    final permision = await Permission.notification.request();
    if (permision.isGranted) {
      debugPrint('permission granted');
    } else {
      debugPrint('permission not granted');
    }
  }
}
