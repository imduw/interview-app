import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart' as conn;

class ConnectivityService {
  final _connectivity = conn.Connectivity();

  // Keep generic to avoid type mismatch across plugin versions
  Stream get onConnectivityChanged => _connectivity.onConnectivityChanged;

  Future check() => _connectivity.checkConnectivity();
}
