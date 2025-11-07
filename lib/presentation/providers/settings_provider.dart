import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Sistem ayarları
  String _systemStatus = 'online';
  int _serverLoad = 42;
  int _memoryUsage = 65;
  int _diskUsage = 38;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get systemStatus => _systemStatus;
  int get serverLoad => _serverLoad;
  int get memoryUsage => _memoryUsage;
  int get diskUsage => _diskUsage;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    // Simüle API çağrısı
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSystemStatus(String status) async {
    _systemStatus = status;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}