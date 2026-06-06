import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/attachment.dart';
import '../../../core/models/chat_message.dart';
import '../../conversations/providers/conversation_provider.dart';
import '../../settings/providers/settings_provider.dart';

class ChatState {
  const ChatState({
    this.pendingAttachments = const [],
    this.isSending = false,
    this.error,
  });

  final List<Attachment> pendingAttachments;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    List<Attachment>? pendingAttachments,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.ref) : super(const ChatState());

  final Ref ref;
  static const _uuid = Uuid();

  void addAttachments(List<Attachment> attachments) {
    state = state.copyWith(
      pendingAttachments: [...state.pendingAttachments, ...attachments],
      clearError: true,
    );
  }

  void removeAttachment(String id) {
    state = state.copyWith(
      pendingAttachments: state.pendingAttachments.where((attachment) => attachment.id != id).toList(),
    );
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty && state.pendingAttachments.isEmpty) return;
    if (state.isSending) return;

    final settingsState = ref.read(settingsProvider);
    if (state.pendingAttachments.any((attachment) => attachment.isImage) &&
        !settingsState.settings.visionEnabled) {
      state = state.copyWith(error: 'Enable vision support in Settings before sending images.');
      return;
    }

    var conversationState = ref.read(conversationProvider);
    if (conversationState.selectedConversation == null) {
      await ref.read(conversationProvider.notifier).newConversation();
      conversationState = ref.read(conversationProvider);
    }
    final conversation = conversationState.selectedConversation;
    if (conversation == null) return;

    final attachments = List<Attachment>.from(state.pendingAttachments);
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: _composePrompt(text, attachments),
      createdAt: DateTime.now(),
      attachments: attachments,
    );
    final assistantMessage = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    var messages = [...conversation.messages, userMessage, assistantMessage];

    state = state.copyWith(pendingAttachments: const [], isSending: true, clearError: true);
    await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);

    try {
      final service = ref.read(lmStudioServiceProvider);
      final stream = service.streamChat(
        settings: settingsState.settings,
        apiKey: settingsState.apiKey,
        messages: messages.where((message) => !message.isStreaming).toList(),
      );
      var content = '';
      await for (final token in stream) {
        content += token;
        messages = [
          ...messages.where((message) => message.id != assistantMessage.id),
          assistantMessage.copyWith(content: content, isStreaming: true),
        ];
        await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);
      }
      messages = [
        ...messages.where((message) => message.id != assistantMessage.id),
        assistantMessage.copyWith(content: content, isStreaming: false),
      ];
      await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);
      state = state.copyWith(isSending: false);
    } catch (error) {
      messages = [
        ...messages.where((message) => message.id != assistantMessage.id),
        assistantMessage.copyWith(content: '', isStreaming: false, error: error.toString()),
      ];
      await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);
      state = state.copyWith(isSending: false, error: error.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final conversation = ref.read(conversationProvider).selectedConversation;
    if (conversation == null) return;
    final messages = conversation.messages.where((message) => message.id != messageId).toList();
    await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);
  }

  Future<void> regenerate(ChatMessage assistantMessage) async {
    final conversation = ref.read(conversationProvider).selectedConversation;
    if (conversation == null || assistantMessage.role != ChatRole.assistant) return;
    final index = conversation.messages.indexWhere((message) => message.id == assistantMessage.id);
    if (index <= 0) return;
    final priorMessages = conversation.messages.take(index).toList();
    final replacement = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    var messages = [...priorMessages, replacement];
    state = state.copyWith(isSending: true, clearError: true);
    await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);

    try {
      final settingsState = ref.read(settingsProvider);
      final service = ref.read(lmStudioServiceProvider);
      var content = '';
      await for (final token in service.streamChat(
        settings: settingsState.settings,
        apiKey: settingsState.apiKey,
        messages: priorMessages,
      )) {
        content += token;
        messages = [
          ...priorMessages,
          replacement.copyWith(content: content, isStreaming: true),
        ];
        await ref.read(conversationProvider.notifier).upsertMessages(conversation.id, messages);
      }
      await ref.read(conversationProvider.notifier).upsertMessages(
        conversation.id,
        [...priorMessages, replacement.copyWith(content: content, isStreaming: false)],
      );
      state = state.copyWith(isSending: false);
    } catch (error) {
      await ref.read(conversationProvider.notifier).upsertMessages(
        conversation.id,
        [...priorMessages, replacement.copyWith(isStreaming: false, error: error.toString())],
      );
      state = state.copyWith(isSending: false, error: error.toString());
    }
  }

  String _composePrompt(String text, List<Attachment> attachments) {
    final buffer = StringBuffer(text);
    for (final attachment in attachments) {
      if (attachment.isText && attachment.textContent != null) {
        buffer
          ..writeln()
          ..writeln()
          ..writeln('File: ${attachment.name}')
          ..writeln('```')
          ..writeln(attachment.textContent)
          ..writeln('```');
      } else if (!attachment.isImage) {
        buffer
          ..writeln()
          ..writeln()
          ..writeln('Attached file: ${attachment.name}');
      }
    }
    return buffer.toString().trim();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
