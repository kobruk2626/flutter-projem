import 'package:photo_momento/data/models/customer_model.dart';

class CustomerRepository {
  Future<List<CustomerModel>> getCustomers() async {
    // Simüle edilmiş veri - gerçek uygulamada API'den gelecek
    await Future.delayed(const Duration(seconds: 2));

    return [
      CustomerModel(
        id: '1',
        name: 'Ahmet Memet',
        email: 'ahmet@email.com',
        phone: '+905551234567',
        city: 'İstanbul',
        totalOrders: 15,
        totalSpent: 2150.0,
        rating: 4.8,
        registeredAt: DateTime(2023, 3, 15),
        lastOrderAt: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
      ),
      CustomerModel(
        id: '2',
        name: 'Ayşe Yılmaz',
        email: 'ayse@email.com',
        phone: '+905559876543',
        city: 'İstanbul',
        totalOrders: 8,
        totalSpent: 1200.0,
        rating: 4.9,
        registeredAt: DateTime(2023, 11, 20),
        lastOrderAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      ),
    ];
  }

  Future<void> updateCustomerStatus(String customerId, bool isActive) async {
    // Gerçek uygulamada API'ye istek atılacak
    await Future.delayed(const Duration(seconds: 1));
  }
}