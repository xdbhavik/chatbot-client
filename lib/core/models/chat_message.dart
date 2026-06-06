import 'attachment.dart';

enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
    this.isStreaming = false,
    this.error,
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final List<Attachment> attachments;
  final bool isStreaming;
  final String? error;

  ChatMessage copyWith({
    String? content,
    List<Attachment>? attachments,
    bool? isStreaming,
    String? error,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      attachments: attachments ?? this.attachments,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
        'isStreaming': isStreaming,
        'error': error,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: ChatRole.values.byName(json['role'] as String),
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        attachments: (json['attachments'] as List<dynamic>? ?? const [])
            .map((item) => Attachment.fromJson(item as Map<String, dynamic>))
            .toList(),
        isStreaming: json['isStreaming'] as bool? ?? false,
        error: json['error'] as String?,
      );
}
