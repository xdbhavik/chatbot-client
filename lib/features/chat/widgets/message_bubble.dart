import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_message.dart';
import 'attachment_chip.dart';
import 'markdown_message.dart';
import 'typing_indicator.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.role == ChatRole.user;
    final color = isUser ? colors.primaryContainer.withValues(alpha: 0.7) : colors.surfaceContainerHighest;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onLongPress: () => _showActions(context, ref),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isUser ? Icons.person_outline : Icons.auto_awesome, size: 18),
                        const SizedBox(width: 8),
                        Text(isUser ? 'You' : 'Assistant', style: Theme.of(context).textTheme.labelLarge),
                        if (message.isStreaming) ...[
                          const SizedBox(width: 8),
                          const SizedBox(width: 24, child: TypingIndicator()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (message.error != null)
                      Text(message.error!, style: TextStyle(color: colors.error))
                    else
                      MarkdownMessage(content: message.content),
                    if (message.attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.attachments
                            .map((attachment) => AttachmentChip(attachment: attachment))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () => Navigator.of(context).pop('copy'),
            ),
            if (message.role == ChatRole.assistant)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Regenerate response'),
                onTap: () => Navigator.of(context).pop('regenerate'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete message'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;
    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: message.content));
      case 'regenerate':
        await ref.read(chatProvider.notifier).regenerate(message);
      case 'delete':
        await ref.read(chatProvider.notifier).deleteMessage(message.id);
    }
  }
}
