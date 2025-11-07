import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final UserRole role;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
    this.role = UserRole.customer,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      profileImage: data['profileImage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null ? (data['lastLogin'] as Timestamp).toDate() : null,
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == (data['role'] ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      addresses: (data['addresses'] as List? ?? []).map((e) => Address.fromMap(e)).toList(),
      paymentMethods: (data['paymentMethods'] as List? ?? []).map((e) => PaymentMethod.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'role': role.toString().split('.').last,
      'addresses': addresses.map((e) => e.toMap()).toList(),
      'paymentMethods': paymentMethods.map((e) => e.toMap()).toList(),
    };
  }

  // Varsayılan adresi getir
  Address? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // Varsayılan ödeme yöntemini getir
  PaymentMethod? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((payment) => payment.isDefault);
    } catch (e) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }

  // Admin mi kontrolü
  bool get isAdmin => role == UserRole.admin;

  // Operatör mü kontrolü
  bool get isOperator => role == UserRole.operator;

  // Kopyalama metodu
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
    UserRole? role,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      role: role ?? this.role,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class Address {
  final String id;
  final String title;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String district;
  final String city;
  final String postalCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.district,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'district': district,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  // Tam adresi getir
  String get fullAddress {
    final lines = [addressLine1];
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      lines.add(addressLine2!);
    }
    lines.addAll([district, city, postalCode]);
    return lines.where((line) => line.isNotEmpty).join(', ');
  }

  // Kopyalama metodu
  Address copyWith({
    String? id,
    String? title,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? district,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      district: district ?? this.district,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentMethod {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolder: map['cardHolder'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
    };
  }

  // Maskelenmiş kart numarası
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Kopyalama metodu
  PaymentMethod copyWith({
    String? id,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

enum UserRole {
  customer,
  admin,
  operator,
}