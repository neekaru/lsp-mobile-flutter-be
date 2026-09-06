import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? userId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.data,
    this.isRead = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'data': data,
        'isRead': isRead,
        'userId': userId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: json['type'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        isRead: json['isRead'] as bool? ?? false,
        userId: json['userId']?.toString() ?? json['data']?['user_id']?.toString(),
      );

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    String? userId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
    );
  }
}

class AppNotificationStorage {
  AppNotificationStorage._privateConstructor();
  static final AppNotificationStorage instance = AppNotificationStorage._privateConstructor();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
  );

  static const _legacyKey = 'app_notifications_list';

  Future<String?> _resolveCurrentUserId() async {
    final memoryId = AuthRepository.currentUserInstance?.id;
    if (memoryId != null && memoryId.isNotEmpty) {
      return memoryId;
    }
    try {
      final profile = await TokenStorage.instance.getUserProfile();
      if (profile != null && profile.id.isNotEmpty) {
        return profile.id;
      }
    } catch (_) {}
    return null;
  }

  Future<String> _getStorageKey({String? explicitUserId}) async {
    final uid = explicitUserId ?? await _resolveCurrentUserId();
    if (uid != null && uid.isNotEmpty) {
      return 'app_notifications_user_$uid';
    }
    return 'app_notifications_guest';
  }

  Future<List<AppNotification>> getNotifications({String? explicitUserId}) async {
    try {
      final currentUid = explicitUserId ?? await _resolveCurrentUserId();
      final key = await _getStorageKey(explicitUserId: currentUid);
      final jsonStr = await _storage.read(key: key);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(jsonStr);
      final list = decodedList
          .map((item) => AppNotification.fromJson(item))
          // STRICT ISOLATION: Exclude notifications that belong to a different user
          .where((n) {
            if (currentUid == null || currentUid.isEmpty) {
              return n.userId == null || n.userId!.isEmpty;
            }
            return n.userId == null || n.userId == currentUid;
          })
          .toList();
      
      // Sort newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(
    String title,
    String body,
    String type,
    Map<String, dynamic> data, {
    String? targetUserId,
  }) async {
    try {
      final notifUserId = targetUserId ??
          data['user_id']?.toString() ??
          await _resolveCurrentUserId();

      final currentUid = await _resolveCurrentUserId();

      // If targetUserId is explicitly for another user and does not match the active user,
      // save to that target user's isolated storage so it won't bleed into the current user
      final key = await _getStorageKey(explicitUserId: notifUserId);
      final list = await getNotifications(explicitUserId: notifUserId);
      
      final newNotif = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        data: data,
        isRead: false,
        userId: notifUserId,
      );

      // Deduplicate: If an identical notification arrived recently, update it instead of adding duplicate spam
      final existingIndex = list.indexWhere((n) =>
          n.title == title &&
          n.body == body &&
          n.type == type &&
          DateTime.now().difference(n.timestamp).inMinutes < 15);

      if (existingIndex != -1) {
        list[existingIndex] = list[existingIndex].copyWith(
          timestamp: DateTime.now(),
          data: data,
          isRead: false,
          userId: notifUserId,
        );
      } else {
        list.insert(0, newNotif);
      }
      
      // Keep only last 100 notifications to prevent memory issues
      if (list.length > 100) {
        list.removeRange(100, list.length);
      }

      await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      final key = await _getStorageKey();
      final list = await getNotifications();
      final index = list.indexWhere((element) => element.id == id);
      if (index != -1) {
        list[index] = list[index].copyWith(isRead: true);
        await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final key = await _getStorageKey();
      final list = await getNotifications();
      final updatedList = list.map((e) => e.copyWith(isRead: true)).toList();
      await _storage.write(key: key, value: jsonEncode(updatedList.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      final key = await _getStorageKey();
      final list = await getNotifications();
      list.removeWhere((element) => element.id == id);
      await _storage.write(key: key, value: jsonEncode(list.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final key = await _getStorageKey();
      await _storage.delete(key: key);
      // Also clean up any legacy unscoped storage
      await _storage.delete(key: _legacyKey);
    } catch (_) {}
  }

  Future<int> getUnreadCount({String? explicitUserId}) async {
    try {
      final list = await getNotifications(explicitUserId: explicitUserId);
      return list.where((element) => !element.isRead).length;
    } catch (_) {
      return 0;
    }
  }
}
