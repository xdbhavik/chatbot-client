import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class MarkdownMessage extends StatelessWidget {
  const MarkdownMessage({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MarkdownBody(
      data: content.isEmpty ? ' ' : content,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        codeblockDecoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.primary, width: 3)),
        ),
      ),
      builders: {
        'code': CodeElementBuilder(),
      },
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final text = element.textContent;
    if (element.tag != 'code' || !text.contains('\n')) return null;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SelectableText(text, style: preferredStyle),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            tooltip: 'Copy code',
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () => Clipboard.setData(ClipboardData(text: text)),
          ),
        ),
      ],
    );
  }
}
