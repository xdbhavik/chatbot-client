import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/file_utils.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/chat_provider.dart';
import 'attachment_chip.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({super.key});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    ref.listen(chatProvider.select((state) => state.error), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat.pendingAttachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chat.pendingAttachments
                          .map(
                            (attachment) => AttachmentChip(
                              attachment: attachment,
                              onDeleted: () => ref.read(chatProvider.notifier).removeAttachment(attachment.id),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Attach file',
                    onPressed: chat.isSending
                        ? null
                        : () async {
                            final files = await FileUtils.pickFiles();
                            ref.read(chatProvider.notifier).addAttachments(files);
                          },
                    icon: const Icon(Icons.attach_file),
                  ),
                  IconButton(
                    tooltip: 'Attach image',
                    onPressed: chat.isSending
                        ? null
                        : () async {
                            final images = await ImageUtils.pickImages();
                            ref.read(chatProvider.notifier).addAttachments(images);
                          },
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Message LM Studio...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: chat.isSending
                        ? null
                        : () async {
                            final text = _controller.text;
                            _controller.clear();
                            await ref.read(chatProvider.notifier).sendMessage(text);
                            _focusNode.requestFocus();
                          },
                    icon: chat.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
