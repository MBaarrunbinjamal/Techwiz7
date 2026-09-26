import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class expenseSyncService {
  static final expenseSyncService _instance = expenseSyncService._internal();
  factory expenseSyncService() => _instance;
  expenseSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    // App open hote hi ek dafa check (agar pehle se internet ho)
    DatabaseHelper().syncPendingexpense();

    // Internet wapas aane par khud-ba-khud sync
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = results.any((r) => r != ConnectivityResult.none);
      if (hasInternet) {
        DatabaseHelper().syncPendingexpense();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}