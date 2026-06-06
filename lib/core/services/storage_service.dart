import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/conversation.dart';

class StorageService {
  static const _fileName = 'conversations.json';

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File(p.join(directory.path, _fileName));
  }

  Future<List<Conversation>> loadConversations() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => Conversation.fromJson(item as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversations(List<Conversation> conversations) async {
    final file = await _file();
    final json = conversations.map((conversation) => conversation.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}
