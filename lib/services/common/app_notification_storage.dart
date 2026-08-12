import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.data,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'data': data,
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: json['type'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        isRead: json['isRead'] as bool? ?? false,
      );

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}

class AppNotificationStorage {
  AppNotificationStorage._privateConstructor();
  static final AppNotificationStorage instance = AppNotificationStorage._privateConstructor();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const _notificationsKey = 'app_notifications_list';

  Future<List<AppNotification>> getNotifications() async {
    try {
      final jsonStr = await _storage.read(key: _notificationsKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(jsonStr);
      final list = decodedList.map((item) => AppNotification.fromJson(item)).toList();
      
      // Sort newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(String title, String body, String type, Map<String, dynamic> data) async {
    try {
      final list = await getNotifications();
      
      final newNotif = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        data: data,
        isRead: false,
      );

      list.insert(0, newNotif);
      
      // Keep only last 100 notifications to prevent memory issues
      if (list.length > 100) {
        list.removeRange(100, list.length);
      }

      await _storage.write(key: _notificationsKey, value: jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      final list = await getNotifications();
      final index = list.indexWhere((element) => element.id == id);
      if (index != -1) {
        list[index] = list[index].copyWith(isRead: true);
        await _storage.write(key: _notificationsKey, value: jsonEncode(list.map((e) => e.toJson()).toList()));
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final list = await getNotifications();
      final updatedList = list.map((e) => e.copyWith(isRead: true)).toList();
      await _storage.write(key: _notificationsKey, value: jsonEncode(updatedList.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      final list = await getNotifications();
      list.removeWhere((element) => element.id == id);
      await _storage.write(key: _notificationsKey, value: jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _notificationsKey);
    } catch (_) {}
  }

  Future<int> getUnreadCount() async {
    try {
      final list = await getNotifications();
      return list.where((element) => !element.isRead).length;
    } catch (_) {
      return 0;
    }
  }
}
