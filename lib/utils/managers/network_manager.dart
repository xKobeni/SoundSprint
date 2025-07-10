import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isConnected = true;
  bool _isInitialized = false;

  /// Get connection status stream
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Initialize network monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check initial connection status
      final connectivityResult = await _connectivity.checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;
      _connectionStatusController.add(_isConnected);

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        final wasConnected = _isConnected;
        _isConnected = result != ConnectivityResult.none;
        
        if (wasConnected != _isConnected) {
          _connectionStatusController.add(_isConnected);
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('NetworkManager initialization error: $e');
      // Assume connected if we can't determine status
      _isConnected = true;
      _connectionStatusController.add(_isConnected);
    }
  }

  /// Check if we have internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;
      return _isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get detailed connection information
  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return {
        'isConnected': connectivityResult != ConnectivityResult.none,
        'connectionType': connectivityResult.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isConnected': false,
        'connectionType': 'unknown',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
} 