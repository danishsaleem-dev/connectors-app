/// One suggested question shown as a chip when the chat opens.
class ChatSuggestion {
  final String id;
  final String question;

  const ChatSuggestion({required this.id, required this.question});

  factory ChatSuggestion.fromJson(Map<String, dynamic> json) {
    return ChatSuggestion(id: json['id'] as String, question: json['question'] as String);
  }
}

/// The opening state of the chat — greeting plus the suggested chips,
/// from GET /api/mobile/chat.
class ChatIntro {
  final String greeting;
  final List<ChatSuggestion> suggested;

  const ChatIntro({required this.greeting, required this.suggested});

  factory ChatIntro.fromJson(Map<String, dynamic> json) {
    return ChatIntro(
      greeting: json['greeting'] as String,
      suggested: (json['suggested'] as List)
          .cast<Map<String, dynamic>>()
          .map(ChatSuggestion.fromJson)
          .toList(),
    );
  }
}

class ChatLink {
  final String href;
  final String label;

  const ChatLink({required this.href, required this.label});

  factory ChatLink.fromJson(Map<String, dynamic> json) {
    return ChatLink(href: json['href'] as String, label: json['label'] as String);
  }
}

/// A reply from POST /api/mobile/chat — same three-way shape the website's
/// matcher returns (answer / smalltalk / escalate / unknown), collapsed to
/// "does this need a human" since the app shows all four the same way and
/// only "escalate"/"unknown" offer the send-to-Connectors follow-up.
class ChatReply {
  final String kind;
  final String answer;
  final ChatLink? link;

  const ChatReply({required this.kind, required this.answer, this.link});

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      kind: json['kind'] as String,
      answer: json['answer'] as String,
      link: json['link'] == null ? null : ChatLink.fromJson(json['link'] as Map<String, dynamic>),
    );
  }

  bool get needsHuman => kind == 'escalate' || kind == 'unknown';
}
