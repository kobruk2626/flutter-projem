import 'package:flutter/material.dart';
import 'package:photo_momento/domain/repositories/auth_repository.dart';
import 'package:photo_momento/data/models/user_model.dart';
import 'package:photo_momento/data/repositories/auth_repository_impl.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;

  // Stream listener for auth state changes
  void initialize() {
    _authRepository.userStream.listen((user) {
      _user = user;
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _user = await _authRepository.signInWithEmailAndPassword(email, password);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Giriş yapılırken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String name, String? phone) async {
    try {
      _setLoading(true);
      _user = await _authRepository.registerWithEmailAndPassword(email, password, name, phone);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Kayıt olurken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authRepository.signOut();
      _user = null;
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Çıkış yapılırken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authRepository.resetPassword(email);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Şifre sıfırlama işlemi sırasında bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      _setLoading(true);
      await _authRepository.updateUserProfile(updatedUser);
      _user = updatedUser;
      _error = null;
      notifyListeners();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Profil güncellenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Kullanıcı bilgileri yenilenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Kullanıcı adını getir
  String get displayName {
    if (_user == null) return 'Misafir';
    return _user!.name.isNotEmpty ? _user!.name : _user!.email.split('@').first;
  }

  // Kullanıcı email'ini getir
  String get email {
    return _user?.email ?? '';
  }

  // Profil resmi URL'sini getir
  String? get profileImage {
    return _user?.profileImage;
  }

  // Telefon numarasını getir
  String? get phone {
    return _user?.phone;
  }

  // Kullanıcı rollerini kontrol et
  bool get isOperator => _user?.role == UserRole.operator;
  bool get isCustomer => _user?.role == UserRole.customer;

  // Adresleri getir
  List<Address> get addresses {
    return _user?.addresses ?? [];
  }

  // Ödeme yöntemlerini getir
  List<PaymentMethod> get paymentMethods {
    return _user?.paymentMethods ?? [];
  }
}