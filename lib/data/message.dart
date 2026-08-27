import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// One row from GET /api/mobile/messages — the org's single thread with
/// the Connectors team (see that route's doc comment: there is no org-to-
/// org thread anywhere in the product).
class Message {
  final String id;
  final String authorName;
  final bool authorIsAdmin;
  final String body;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.authorName,
    required this.authorIsAdmin,
    required this.body,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorIsAdmin: json['authorIsAdmin'] as bool,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Process-wide cache of the org's thread, plus a crude local "seen"
/// marker for the nav badge — there's no read-state on the server (the
/// `messages` table doesn't track it), so this only counts messages that
/// arrived since the Messages tab was last actually opened this session
/// (see AppShell's _goTo), not a durable unread count.
class MessagesStore {
  MessagesStore._();

  static final thread = ValueNotifier<List<Message>>([]);
  static int _lastSeenCount = 0;

  static Future<void> refresh() async {
    thread.value = await ApiClient.fetchMessages();
  }

  static void markSeen() => _lastSeenCount = thread.value.length;

  static int get unreadCount {
    final total = thread.value.length;
    return total > _lastSeenCount ? total - _lastSeenCount : 0;
  }
}
