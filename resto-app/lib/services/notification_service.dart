import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import '../models/notification_item.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getNotifications({bool unreadOnly = false}) async {
    try {
      final url = unreadOnly
          ? '${ApiConfig.notifications}?unread_only=true'
          : ApiConfig.notifications;
      final response = await _apiService.get(url);
      final data = response.data;
      if (data is! Map) return {'success': false, 'data': <NotificationItem>[], 'unread_count': 0};
      final list = (data['data'] as List? ?? [])
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final unreadCount = (data['unread_count'] as num?)?.toInt() ?? 0;
      return {'success': true, 'data': list, 'unread_count': unreadCount};
    } on DioException catch (e) {
      return {
        'success': false,
        'data': <NotificationItem>[],
        'unread_count': 0,
        'message': (e.response?.data is Map ? (e.response!.data as Map)['message'] : null) ?? 'Erreur réseau',
      };
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConfig.notificationsUnreadCount);
      final data = response.data;
      if (data is Map && data['unread_count'] != null) {
        return (data['unread_count'] as num).toInt();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final response = await _apiService.patch(ApiConfig.notificationMarkRead(id));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post(ApiConfig.notificationsMarkAllRead);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
