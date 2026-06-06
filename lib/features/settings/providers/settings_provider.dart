import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_settings.dart';
import '../../../core/services/lm_studio_service.dart';
import '../../../core/services/settings_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup.');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(preferences: ref.watch(sharedPreferencesProvider));
});

final lmStudioServiceProvider = Provider<LmStudioService>((ref) => LmStudioService());

class SettingsState {
  const SettingsState({
    required this.settings,
    this.apiKey = '',
    this.models = const [],
    this.isLoadingModels = false,
    this.isTestingConnection = false,
    this.message,
  });

  final AppSettings settings;
  final String apiKey;
  final List<String> models;
  final bool isLoadingModels;
  final bool isTestingConnection;
  final String? message;

  SettingsState copyWith({
    AppSettings? settings,
    String? apiKey,
    List<String>? models,
    bool? isLoadingModels,
    bool? isTestingConnection,
    String? message,
    bool clearMessage = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      apiKey: apiKey ?? this.apiKey,
      models: models ?? this.models,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._settingsService, this._lmStudioService)
      : super(const SettingsState(settings: AppSettings())) {
    _load();
  }

  final SettingsService _settingsService;
  final LmStudioService _lmStudioService;

  Future<void> _load() async {
    final settings = _settingsService.loadSettings();
    final apiKey = await _settingsService.loadApiKey();
    state = state.copyWith(settings: settings, apiKey: apiKey);
    await discoverModels(silent: true);
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = state.copyWith(settings: settings, clearMessage: true);
    await _settingsService.saveSettings(settings);
  }

  Future<void> updateApiKey(String apiKey) async {
    state = state.copyWith(apiKey: apiKey, clearMessage: true);
    await _settingsService.saveApiKey(apiKey);
  }

  Future<void> discoverModels({bool silent = false}) async {
    state = state.copyWith(isLoadingModels: true, clearMessage: true);
    try {
      final models = await _lmStudioService.fetchModels(state.settings, state.apiKey);
      var settings = state.settings;
      if (settings.model.isEmpty && models.isNotEmpty) {
        settings = settings.copyWith(model: models.first);
        await _settingsService.saveSettings(settings);
      }
      state = state.copyWith(
        settings: settings,
        models: models,
        isLoadingModels: false,
        message: silent ? null : 'Found ${models.length} model${models.length == 1 ? '' : 's'}.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingModels: false,
        message: silent ? null : error.toString(),
      );
    }
  }

  Future<void> testConnection() async {
    state = state.copyWith(isTestingConnection: true, clearMessage: true);
    try {
      await _lmStudioService.testConnection(state.settings, state.apiKey);
      state = state.copyWith(isTestingConnection: false, message: 'Connected to LM Studio.');
    } catch (error) {
      state = state.copyWith(isTestingConnection: false, message: error.toString());
    }
  }

  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref.watch(settingsServiceProvider),
    ref.watch(lmStudioServiceProvider),
  );
});
