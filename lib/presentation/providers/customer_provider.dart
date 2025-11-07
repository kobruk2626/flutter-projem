import 'package:flutter/material.dart';
import 'package:photo_momento/data/models/customer_model.dart';
import 'package:photo_momento/data/repositories/customer_repository.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerRepository _customerRepository;

  CustomerProvider(this._customerRepository);

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // İstatistikler
  int get activeCustomersCount => _customers.where((c) => c.isActive).length;
  int get newCustomersCount => _customers.where((c) => c.isNew).length;
  int get loyalCustomersCount => _customers.where((c) => c.isLoyal).length;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _customerRepository.getCustomers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomerStatus(String customerId, bool isActive) async {
    try {
      await _customerRepository.updateCustomerStatus(customerId, isActive);
      await loadCustomers(); // Listeyi yenile
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}