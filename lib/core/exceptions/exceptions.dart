// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Authentication exceptions
class AuthException extends AppException {
  const AuthException(String message, {String? code}) : super(message, code: code);
}

// Product exceptions
class ProductException extends AppException {
  const ProductException(String message, {String? code}) : super(message, code: code);
}

// Order exceptions
class OrderException extends AppException {
  const OrderException(String message, {String? code}) : super(message, code: code);
}

// Photo exceptions
class PhotoException extends AppException {
  const PhotoException(String message, {String? code}) : super(message, code: code);
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code}) : super(message, code: code);
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(String message, {String? code}) : super(message, code: code);
}

// Common error messages
class ErrorMessages {
  static const String networkError = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
  static const String serverError = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String unauthorized = 'Bu işlem için yetkiniz yok.';
  static const String notFound = 'İstenilen kaynak bulunamadı.';
  static const String unknownError = 'Bilinmeyen bir hata oluştu.';

  // Auth error messages
  static const String invalidEmail = 'Geçersiz e-posta adresi.';
  static const String userDisabled = 'Bu kullanıcı devre dışı bırakılmış.';
  static const String userNotFound = 'Kullanıcı bulunamadı.';
  static const String wrongPassword = 'Yanlış şifre.';
  static const String emailAlreadyInUse = 'Bu e-posta adresi zaten kullanılıyor.';
  static const String weakPassword = 'Şifre çok zayıf.';
  static const String operationNotAllowed = 'Bu işleme izin verilmiyor.';

  // Product error messages
  static const String productNotFound = 'Ürün bulunamadı.';
  static const String insufficientStock = 'Yetersiz stok.';
  static const String invalidProductData = 'Geçersiz ürün verisi.';

  // Order error messages
  static const String orderNotFound = 'Sipariş bulunamadı.';
  static const String invalidOrderStatus = 'Geçersiz sipariş durumu.';
  static const String orderCancellationFailed = 'Sipariş iptal edilemedi.';

  // Photo error messages
  static const String fileTooLarge = 'Dosya boyutu çok büyük.';
  static const String invalidFileType = 'Geçersiz dosya türü.';
  static const String photoUploadFailed = 'Fotoğraf yükleme başarısız.';
  static const String photoSelectionFailed = 'Fotoğraf seçimi başarısız.';
}