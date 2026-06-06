import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/router.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../conversations/providers/conversation_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(conversationProvider);
    final conversation = conversationState.selectedConversation;
    final settingsState = ref.watch(settingsProvider);

    return AdaptiveScaffold(
      title: conversation?.title ?? 'LM Studio Chat',
      body: Column(
        children: [
          _ChatHeader(
            title: conversation?.title ?? 'LM Studio Chat',
            model: settingsState.settings.model,
          ),
          Expanded(
            child: conversationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : conversation == null || conversation.messages.isEmpty
                    ? const _EmptyChat()
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: conversation.messages.length,
                        itemBuilder: (context, index) {
                          final message = conversation.messages.reversed.elementAt(index);
                          return MessageBubble(message: message);
                        },
                      ),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({required this.title, required this.model});

  final String title;
  final String model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    model.isEmpty ? 'No model selected' : model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () {
                ref.read(appRouterProvider.notifier).state =
                    const AppRouterState(route: AppRoute.settings);
              },
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChat extends ConsumerWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Start a local chat',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect to LM Studio at localhost, choose a model, and send a message.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ref.read(appRouterProvider.notifier).state =
                      const AppRouterState(route: AppRoute.settings);
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
