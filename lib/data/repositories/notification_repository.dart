import 'dart:convert';
import 'package:photo_momento/data/models/notification_model.dart';
import 'package:photo_momento/core/services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  // Bildirim geçmişini getir
  Future<List<NotificationModel>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }
      if (type != null) {
        params['type'] = type;
      }

      final response = await _apiService.get('/notifications/history', params: params);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      } else {
        throw Exception('Bildirim geçmişi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bildirim geçmişi yüklenirken hata: $e');
    }
  }

  // Sipariş bildirimi gönder
  Future<void> sendOrderNotification({
    required String orderId,
    required String customerId,
    required String type,
    required String message,
    required List<String> channels,
    String? customMessage,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'order_id': orderId,
        'customer_id': customerId,
        'type': type,
        'message': message,
        'channels': channels,
        'custom_message': customMessage,
      };

      final response = await _apiService.post('/notifications/send', body: body);

      if (response.statusCode != 200) {
        throw Exception('Bildirim gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bildirim gönderilirken hata: $e');
    }
  }

  // SMS bildirimi gönder
  Future<void> sendSMSNotification({
    required String phone,
    required String message,
    required String templateId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'phone': phone,
        'message': message,
        'template_id': templateId,
      };

      final response = await _apiService.post('/notifications/sms', body: body);

      if (response.statusCode != 200) {
        throw Exception('SMS gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('SMS gönderilirken hata: $e');
    }
  }

  // E-posta bildirimi gönder
  Future<void> sendEmailNotification({
    required String email,
    required String subject,
    required String body,
    required String templateId,
  }) async {
    try {
      final Map<String, dynamic> emailBody = {
        'email': email,
        'subject': subject,
        'body': body,
        'template_id': templateId,
      };

      final response = await _apiService.post('/notifications/email', body: emailBody);

      if (response.statusCode != 200) {
        throw Exception('E-posta gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('E-posta gönderilirken hata: $e');
    }
  }

  // Push bildirimi gönder
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      final Map<String, dynamic> notificationBody = {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
      };

      final response = await _apiService.post('/notifications/push', body: notificationBody);

      if (response.statusCode != 200) {
        throw Exception('Push bildirimi gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Push bildirimi gönderilirken hata: $e');
    }
  }

  // Bildirim şablonlarını getir
  Future<List<NotificationTemplate>> getNotificationTemplates() async {
    try {
      final response = await _apiService.get('/notifications/templates');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotificationTemplate.fromJson(item)).toList();
      } else {
        throw Exception('Şablonlar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Şablonlar yüklenirken hata: $e');
    }
  }

  // Bildirim şablonunu güncelle
  Future<void> updateNotificationTemplate(NotificationTemplate template) async {
    try {
      final response = await _apiService.put(
        '/notifications/templates/${template.id}',
        body: template.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Şablon güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Şablon güncellenirken hata: $e');
    }
  }

  // Bildirim istatistiklerini getir
  Future<Map<String, dynamic>> getNotificationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiService.get('/notifications/stats', params: params);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('İstatistikler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('İstatistikler yüklenirken hata: $e');
    }
  }

  // Başarısız bildirimi tekrar gönder
  Future<void> retryFailedNotification(String notificationId) async {
    try {
      final response = await _apiService.post(
        '/notifications/$notificationId/retry',
      );

      if (response.statusCode != 200) {
        throw Exception('Bildirim tekrar gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bildirim tekrar gönderilirken hata: $e');
    }
  }
}

class NotificationTemplate {
  final String id;
  final String name;
  final String type;
  final String subject;
  final String body;
  final Map<String, String> variables;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.subject,
    required this.body,
    required this.variables,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      subject: json['subject'],
      body: json['body'],
      variables: Map<String, String>.from(json['variables'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'subject': subject,
      'body': body,
      'variables': variables,
    };
  }

  // Şablon mesajını değişkenlerle doldur
  String formatMessage(Map<String, String> values) {
    String formattedMessage = body;
    values.forEach((key, value) {
      formattedMessage = formattedMessage.replaceAll('{$key}', value);
    });
    return formattedMessage;
  }
}