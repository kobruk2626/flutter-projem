import 'package:flutter/material.dart';

class ReportProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Rapor verileri
  int _totalOrders = 45;
  double _totalRevenue = 12500.0;
  int _newCustomers = 15;
  double _averageRating = 4.8;
  String _systemStatus = 'online';
  int _serverLoad = 42;
  int _memoryUsage = 65;
  int _diskUsage = 38;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;
  int get newCustomers => _newCustomers;
  double get averageRating => _averageRating;
  String get systemStatus => _systemStatus;
  int get serverLoad => _serverLoad;
  int get memoryUsage => _memoryUsage;
  int get diskUsage => _diskUsage;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    // Simüle API çağrısı
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}