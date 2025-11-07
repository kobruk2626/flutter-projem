import 'package:flutter/material.dart';
import 'package:photo_momento/data/models/notification_model.dart';
import 'package:photo_momento/data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationProvider(this._notificationRepository);

  // State variables
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  // Bildirim geçmişini yükle
  Future<void> loadNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getNotificationHistory(
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sipariş bildirimi gönder
  Future<bool> sendOrderNotification({
    required String orderId,
    required String customerId,
    required String type,
    required String message,
    required List<String> channels,
    String? customMessage,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationRepository.sendOrderNotification(
        orderId: orderId,
        customerId: customerId,
        type: type,
        message: message,
        channels: channels,
        customMessage: customMessage,
      );

      // Bildirim geçmişini yenile
      await loadNotificationHistory();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SMS bildirimi gönder
  Future<bool> sendSMSNotification({
    required String phone,
    required String message,
    required String templateId,
  }) async {
    try {
      await _notificationRepository.sendSMSNotification(
        phone: phone,
        message: message,
        templateId: templateId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // E-posta bildirimi gönder
  Future<bool> sendEmailNotification({
    required String email,
    required String subject,
    required String body,
    required String templateId,
  }) async {
    try {
      await _notificationRepository.sendEmailNotification(
        email: email,
        subject: subject,
        body: body,
        templateId: templateId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Push bildirimi gönder
  Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _notificationRepository.sendPushNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Bildirim istatistiklerini yükle
  Future<void> loadNotificationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _notificationRepository.getNotificationStats(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Başarısız bildirimi tekrar gönder
  Future<bool> retryFailedNotification(String notificationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationRepository.retryFailedNotification(notificationId);

      // Bildirim geçmişini yenile
      await loadNotificationHistory();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrelenmiş bildirimleri getir
  List<NotificationModel> getFilteredNotifications({
    String? status,
    String? channel,
    String? type,
  }) {
    return _notifications.where((notification) {
      bool matchesStatus = status == null || notification.status == status;
      bool matchesChannel = channel == null || notification.channel == channel;
      bool matchesType = type == null || notification.type == type;

      return matchesStatus && matchesChannel && matchesType;
    }).toList();
  }

  // Başarı oranını hesapla
  double getSuccessRate() {
    if (_notifications.isEmpty) return 0.0;

    final successfulCount = _notifications
        .where((notification) => notification.status == 'success')
        .length;

    return (successfulCount / _notifications.length) * 100;
  }

  // Kanal bazlı istatistikler
  Map<String, Map<String, int>> getChannelStats() {
    final Map<String, Map<String, int>> channelStats = {};

    for (final notification in _notifications) {
      if (!channelStats.containsKey(notification.channel)) {
        channelStats[notification.channel] = {
          'total': 0,
          'success': 0,
          'failed': 0,
        };
      }

      channelStats[notification.channel]!['total'] =
          channelStats[notification.channel]!['total']! + 1;

      if (notification.status == 'success') {
        channelStats[notification.channel]!['success'] =
            channelStats[notification.channel]!['success']! + 1;
      } else {
        channelStats[notification.channel]!['failed'] =
            channelStats[notification.channel]!['failed']! + 1;
      }
    }

    return channelStats;
  }

  // Hata temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}