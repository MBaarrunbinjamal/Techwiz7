import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:techwiz7/Database_helper/DatabaseHelper.dart';

class IncomeSyncService {
  static final IncomeSyncService _instance = IncomeSyncService._internal();
  factory IncomeSyncService() => _instance;
  IncomeSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    DatabaseHelper().syncPendingIncomes();

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