import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/chat_message.dart';

class LmStudioService {
  LmStudioService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Options _options(String apiKey, {ResponseType? responseType}) {
    return Options(
      responseType: responseType,
      headers: {
        if (apiKey.trim().isNotEmpty) 'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
      },
    );
  }

  String _url(AppSettings settings, String path) {
    final base = settings.endpointUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base$path';
  }

  Future<List<String>> fetchModels(AppSettings settings, String apiKey) async {
    try {
      final response = await _dio.get<dynamic>(
        _url(settings, '/models'),
        options: _options(apiKey),
        queryParameters: const {},
      ).timeout(AppConstants.connectionTimeout);
      final data = response.data as Map<String, dynamic>;
      final models = data['data'] as List<dynamic>? ?? const [];
      return models
          .map((item) => (item as Map<String, dynamic>)['id'] as String?)
          .whereType<String>()
          .toList();
    } on DioException catch (error) {
      throw _friendlyError(error);
    } on TimeoutException {
      throw 'Connection timed out. Check that LM Studio is running.';
    } catch (_) {
      throw 'Could not read models from LM Studio.';
    }
  }

  Future<void> testConnection(AppSettings settings, String apiKey) async {
    final models = await fetchModels(settings, apiKey);
    if (settings.model.isNotEmpty && models.isNotEmpty && !models.contains(settings.model)) {
      throw 'Connected, but model "${settings.model}" was not found.';
    }
  }

  Stream<String> streamChat({
    required AppSettings settings,
    required String apiKey,
    required List<ChatMessage> messages,
  }) async* {
    if (settings.endpointUrl.trim().isEmpty) {
      throw 'Add your LM Studio endpoint in Settings.';
    }
    if (settings.model.trim().isEmpty) {
      throw 'Choose or enter a model in Settings.';
    }

    final response = await _dio
        .post<ResponseBody>(
          _url(settings, '/chat/completions'),
          data: {
            'model': settings.model.trim(),
            'messages': messages.map(_messagePayload).toList(),
            'temperature': settings.temperature,
            'max_tokens': settings.maxTokens,
            'stream': true,
          },
          options: _options(apiKey, responseType: ResponseType.stream),
        )
        .timeout(AppConstants.connectionTimeout)
        .catchError((Object error) {
      if (error is DioException) throw _friendlyError(error);
      if (error is TimeoutException) throw 'Connection timed out. Check that LM Studio is running.';
      throw 'Unable to reach LM Studio.';
    });

    final stream = response.data?.stream;
    if (stream == null) throw 'LM Studio returned an empty response.';

    final lines = stream
        .transform(StreamTransformer<Uint8List, String>.fromBind(utf8.decoder.bind))
        .transform(const LineSplitter())
        .timeout(AppConstants.streamTimeout);

    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final choices = decoded['choices'] as List<dynamic>? ?? const [];
        if (choices.isEmpty) continue;
        final delta = (choices.first as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) yield content;
      } catch (_) {
        continue;
      }
    }
  }

  Map<String, dynamic> _messagePayload(ChatMessage message) {
    if (message.attachments.any((attachment) => attachment.isImage)) {
      return {
        'role': message.role.name,
        'content': [
          {'type': 'text', 'text': message.content},
          ...message.attachments.where((attachment) => attachment.isImage).map(
                (attachment) => {
                  'type': 'image_url',
                  'image_url': {'url': attachment.dataUrl},
                },
              ),
        ],
      };
    }
    return {'role': message.role.name, 'content': message.content};
  }

  String _friendlyError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) return 'The API key was rejected by LM Studio.';
    if (status == 404) return 'LM Studio endpoint was not found. Check the /v1 URL.';
    if (status != null) return 'LM Studio returned HTTP $status.';
    return 'LM Studio is offline or unreachable.';
  }
}
