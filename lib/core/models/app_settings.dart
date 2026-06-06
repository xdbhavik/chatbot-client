import '../constants/app_constants.dart';

class AppSettings {
  const AppSettings({
    this.endpointUrl = AppConstants.defaultEndpoint,
    this.model = '',
    this.temperature = AppConstants.defaultTemperature,
    this.maxTokens = AppConstants.defaultMaxTokens,
    this.themeMode = 'dark',
    this.visionEnabled = false,
  });

  final String endpointUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final String themeMode;
  final bool visionEnabled;

  AppSettings copyWith({
    String? endpointUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    String? themeMode,
    bool? visionEnabled,
  }) {
    return AppSettings(
      endpointUrl: endpointUrl ?? this.endpointUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      themeMode: themeMode ?? this.themeMode,
      visionEnabled: visionEnabled ?? this.visionEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'endpointUrl': endpointUrl,
        'model': model,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'themeMode': themeMode,
        'visionEnabled': visionEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        endpointUrl: json['endpointUrl'] as String? ?? AppConstants.defaultEndpoint,
        model: json['model'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? AppConstants.defaultTemperature,
        maxTokens: json['maxTokens'] as int? ?? AppConstants.defaultMaxTokens,
        themeMode: json['themeMode'] as String? ?? 'dark',
        visionEnabled: json['visionEnabled'] as bool? ?? false,
      );
}
