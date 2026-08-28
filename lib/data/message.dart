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

  /// Only ever set on an admin-authored message — the org's read state of
  /// it (see the website's messages.readAt doc comment on schema.ts).
  /// Never set on the org's own messages; there's no "unread to yourself".
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.authorName,
    required this.authorIsAdmin,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorIsAdmin: json['authorIsAdmin'] as bool,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
    );
  }

  Message copyWith({DateTime? readAt}) => Message(
        id: id,
        authorName: authorName,
        authorIsAdmin: authorIsAdmin,
        body: body,
        createdAt: createdAt,
        readAt: readAt ?? this.readAt,
      );
}

/// Process-wide cache of the org's thread. Also what backs the
/// Notifications tab (see notifications_screen.dart) — an admin-authored
/// message *is* a notification, filtered to a different view of the same
/// data rather than a separate feed, since a message from Connectors is
/// the only thing in the product that's actually real enough to notify on.
class MessagesStore {
  MessagesStore._();

  static final thread = ValueNotifier<List<Message>>([]);

  static Future<void> refresh() async {
    thread.value = await ApiClient.fetchMessages();
  }

  /// Marks the whole thread read at once — same "open the conversation"
  /// semantics as any chat app, not one message at a time. Updates local
  /// state optimistically so the badge clears immediately rather than
  /// waiting on a refetch; a failure just means it stays showing as
  /// unread, which is the safe direction to be wrong in.
  static Future<void> markRead() async {
    final now = DateTime.now();
    thread.value = [
      for (final m in thread.value)
        (m.authorIsAdmin && m.readAt == null) ? m.copyWith(readAt: now) : m,
    ];
    await ApiClient.markMessagesRead();
  }

  static int get unreadCount =>
      thread.value.where((m) => m.authorIsAdmin && m.readAt == null).length;
}
