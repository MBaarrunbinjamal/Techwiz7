import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class expenseSyncService {
  static final expenseSyncService _instance = expenseSyncService._internal();
  factory expenseSyncService() => _instance;
  expenseSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    DatabaseHelper().syncPendingexpense();

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