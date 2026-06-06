import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/attachment.dart';

class FileUtils {
  static const _uuid = Uuid();

  static Future<List<Attachment>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        ...AppConstants.supportedTextExtensions,
        ...AppConstants.supportedBinaryExtensions,
      ],
    );
    if (result == null) return [];
    return result.files.map(_fromPlatformFile).whereType<Attachment>().toList();
  }

  static Attachment? _fromPlatformFile(PlatformFile file) {
    final extension = p.extension(file.name).replaceFirst('.', '').toLowerCase();
    final bytes = file.bytes;
    if (bytes == null || extension.isEmpty) return null;

    if (AppConstants.supportedTextExtensions.contains(extension)) {
      return Attachment(
        id: _uuid.v4(),
        name: file.name,
        extension: extension,
        mimeType: _mimeType(extension),
        kind: AttachmentKind.text,
        textContent: utf8.decode(bytes, allowMalformed: true),
      );
    }

    if (AppConstants.supportedBinaryExtensions.contains(extension)) {
      return Attachment(
        id: _uuid.v4(),
        name: file.name,
        extension: extension,
        mimeType: _mimeType(extension),
        kind: AttachmentKind.binary,
      );
    }
    return null;
  }

  static String _mimeType(String extension) {
    return switch (extension) {
      'txt' => 'text/plain',
      'md' => 'text/markdown',
      'csv' => 'text/csv',
      'json' => 'application/json',
      'pdf' => 'application/pdf',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _ => 'application/octet-stream',
    };
  }
}
