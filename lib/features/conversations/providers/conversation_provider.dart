import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/conversation.dart';
import '../../../core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class ConversationState {
  const ConversationState({
    this.conversations = const [],
    this.selectedConversationId,
    this.isLoading = true,
  });

  final List<Conversation> conversations;
  final String? selectedConversationId;
  final bool isLoading;

  Conversation? get selectedConversation {
    for (final conversation in conversations) {
      if (conversation.id == selectedConversationId) return conversation;
    }
    return conversations.isEmpty ? null : conversations.first;
  }

  ConversationState copyWith({
    List<Conversation>? conversations,
    String? selectedConversationId,
    bool? isLoading,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      selectedConversationId: selectedConversationId ?? this.selectedConversationId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier(this._storageService) : super(const ConversationState()) {
    _load();
  }

  final StorageService _storageService;
  static const _uuid = Uuid();

  Future<void> _load() async {
    final conversations = await _storageService.loadConversations();
    state = ConversationState(
      conversations: conversations,
      selectedConversationId: conversations.isNotEmpty ? conversations.first.id : null,
      isLoading: false,
    );
  }

  Future<void> newConversation() async {
    final now = DateTime.now();
    final conversation = Conversation(
      id: _uuid.v4(),
      title: 'New chat',
      messages: const [],
      createdAt: now,
      updatedAt: now,
    );
    final conversations = [conversation, ...state.conversations];
    state = state.copyWith(conversations: conversations, selectedConversationId: conversation.id);
    await _save(conversations);
  }

  void selectConversation(String id) {
    state = state.copyWith(selectedConversationId: id);
  }

  Future<void> deleteConversation(String id) async {
    final conversations = state.conversations.where((conversation) => conversation.id != id).toList();
    state = ConversationState(
      conversations: conversations,
      selectedConversationId: conversations.isNotEmpty ? conversations.first.id : null,
      isLoading: false,
    );
    await _save(conversations);
  }

  Future<void> upsertMessages(String conversationId, List<ChatMessage> messages) async {
    final now = DateTime.now();
    final conversations = state.conversations.map((conversation) {
      if (conversation.id != conversationId) return conversation;
      return conversation.copyWith(
        title: _titleFor(messages),
        messages: messages,
        updatedAt: now,
      );
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(conversations: conversations, selectedConversationId: conversationId);
    await _save(conversations);
  }

  Future<void> _save(List<Conversation> conversations) {
    return _storageService.saveConversations(conversations);
  }

  String _titleFor(List<ChatMessage> messages) {
    final firstUserMessage = messages.where((message) => message.role == ChatRole.user).firstOrNull;
    if (firstUserMessage == null || firstUserMessage.content.trim().isEmpty) return 'New chat';
    final compact = firstUserMessage.content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.length <= 42) return compact;
    return '${compact.substring(0, 39)}...';
  }
}

final conversationProvider = StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(ref.watch(storageServiceProvider));
});
