import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class IncomeSyncService {
  static final IncomeSyncService _instance = IncomeSyncService._internal();
  factory IncomeSyncService() => _instance;
  IncomeSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    // App open hote hi ek dafa check (agar pehle se internet ho)
    DatabaseHelper().syncPendingIncomes();

    // Internet wapas aane par khud-ba-khud sync
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasInternet = results.any((r) => r != ConnectivityResult.none);
      if (hasInternet) {
        DatabaseHelper().syncPendingIncomes();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}