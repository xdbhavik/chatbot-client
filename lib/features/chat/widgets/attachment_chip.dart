import 'package:flutter/material.dart';

import '../../../core/models/attachment.dart';

class AttachmentChip extends StatelessWidget {
  const AttachmentChip({
    super.key,
    required this.attachment,
    this.onDeleted,
  });

  final Attachment attachment;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final icon = switch (attachment.kind) {
      AttachmentKind.image => Icons.image_outlined,
      AttachmentKind.text => Icons.article_outlined,
      AttachmentKind.binary => Icons.attach_file,
    };
    return InputChip(
      avatar: Icon(icon, size: 18),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(attachment.name, overflow: TextOverflow.ellipsis),
      ),
      onDeleted: onDeleted,
    );
  }
}
