import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/attachment.dart';

class ImageUtils {
  static const _uuid = Uuid();

  static Future<List<Attachment>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedImageExtensions.toList(),
    );
    if (result == null) return [];
    return result.files.map(_fromPlatformFile).whereType<Attachment>().toList();
  }

  static Attachment? _fromPlatformFile(PlatformFile file) {
    final extension = p.extension(file.name).replaceFirst('.', '').toLowerCase();
    final bytes = file.bytes;
    if (bytes == null || !AppConstants.supportedImageExtensions.contains(extension)) return null;
    return Attachment(
      id: _uuid.v4(),
      name: file.name,
      extension: extension,
      mimeType: _mimeType(extension),
      kind: AttachmentKind.image,
      bytesBase64: Attachment.encodeBytes(bytes),
    );
  }

  static String _mimeType(String extension) {
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
