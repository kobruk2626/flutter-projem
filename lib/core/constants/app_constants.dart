class AppConstants {
  // App Info
  static const String appName = 'Photo Momento';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String userPhotosPath = 'user_photos';
  static const String productImagesPath = 'product_images';

  // Order Limits
  static const int maxPhotosPerOrder = 50;
  static const int maxFileSizeMB = 10;

  // Delivery
  static const double standardShippingCost = 15.0;
  static const double freeShippingThreshold = 150.0;
  static const int estimatedDeliveryDays = 3;

  // Payment
  static const double taxRate = 0.18; // %18 KDV

  // Notifications
  static const List<String> orderStatusNotifications = [
    'confirmed',
    'printing',
    'shipped',
    'delivered'
  ];
}