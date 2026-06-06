import 'package:chatbot_app/core/models/app_settings.dart';
import 'package:chatbot_app/core/models/attachment.dart';
import 'package:chatbot_app/core/models/chat_message.dart';
import 'package:chatbot_app/core/models/conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings serialize and deserialize', () {
    const settings = AppSettings(
      endpointUrl: 'http://localhost:1234/v1',
      model: 'qwen3',
      temperature: 0.4,
      maxTokens: 1024,
      themeMode: 'system',
      visionEnabled: true,
    );

    expect(AppSettings.fromJson(settings.toJson()).toJson(), settings.toJson());
  });

  test('conversation graph serialize and deserialize', () {
    final attachment = Attachment(
      id: 'attachment-1',
      name: 'notes.md',
      extension: 'md',
      mimeType: 'text/markdown',
      kind: AttachmentKind.text,
      textContent: '# Notes',
    );
    final message = ChatMessage(
      id: 'message-1',
      role: ChatRole.user,
      content: 'Read this',
      createdAt: DateTime.utc(2026),
      attachments: [attachment],
    );
    final conversation = Conversation(
      id: 'conversation-1',
      title: 'Read this',
      messages: [message],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    expect(Conversation.fromJson(conversation.toJson()).toJson(), conversation.toJson());
  });
}
