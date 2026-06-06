import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../core/constants/app_constants.dart';
import '../../features/conversations/providers/conversation_provider.dart';
import '../../features/conversations/widgets/conversation_tile.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(conversationProvider);
    final selectedId = conversationState.selectedConversation?.id;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: AppConstants.sidebarWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () {
                    ref.read(conversationProvider.notifier).newConversation();
                    ref.read(appRouterProvider.notifier).state = const AppRouterState();
                    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Chat'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                ),
              ),
              Expanded(
                child: conversationState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: conversationState.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversationState.conversations[index];
                          return ConversationTile(
                            conversation: conversation,
                            isSelected: conversation.id == selectedId,
                            onTap: () {
                              ref.read(conversationProvider.notifier).selectConversation(conversation.id);
                              ref.read(appRouterProvider.notifier).state = const AppRouterState();
                              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  ref.read(appRouterProvider.notifier).state =
                      const AppRouterState(route: AppRoute.settings);
                  if (Scaffold.maybeOf(context)?.hasDrawer ?? false) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
