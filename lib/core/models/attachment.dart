import 'dart:convert';

enum AttachmentKind { image, text, binary }

class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.extension,
    required this.mimeType,
    required this.kind,
    this.bytesBase64,
    this.textContent,
  });

  final String id;
  final String name;
  final String extension;
  final String mimeType;
  final AttachmentKind kind;
  final String? bytesBase64;
  final String? textContent;

  bool get isImage => kind == AttachmentKind.image;
  bool get isText => kind == AttachmentKind.text;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'extension': extension,
        'mimeType': mimeType,
        'kind': kind.name,
        'bytesBase64': bytesBase64,
        'textContent': textContent,
      };

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json['id'] as String,
        name: json['name'] as String,
        extension: json['extension'] as String,
        mimeType: json['mimeType'] as String,
        kind: AttachmentKind.values.byName(json['kind'] as String),
        bytesBase64: json['bytesBase64'] as String?,
        textContent: json['textContent'] as String?,
      );

  String? get dataUrl {
    if (!isImage || bytesBase64 == null) return null;
    return 'data:$mimeType;base64,$bytesBase64';
  }

  static String encodeBytes(List<int> bytes) => base64Encode(bytes);
}
