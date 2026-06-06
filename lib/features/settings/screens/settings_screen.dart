import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/app_settings.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _endpointController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final TextEditingController _maxTokensController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(settingsProvider);
    _endpointController = TextEditingController(text: state.settings.endpointUrl);
    _apiKeyController = TextEditingController(text: state.apiKey);
    _modelController = TextEditingController(text: state.settings.model);
    _maxTokensController = TextEditingController(text: state.settings.maxTokens.toString());
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    ref.listen(settingsProvider.select((value) => value.message), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
        ref.read(settingsProvider.notifier).clearMessage();
      }
    });

    _syncControllers(state);

    return AdaptiveScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () {
                  ref.read(appRouterProvider.notifier).state = const AppRouterState();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connection', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint URL',
                    hintText: AppConstants.defaultEndpoint,
                  ),
                  onChanged: (value) => _update(state.settings.copyWith(endpointUrl: value)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    helperText: 'Optional. Sent as Authorization: Bearer when provided.',
                  ),
                  obscureText: true,
                  onChanged: (value) => ref.read(settingsProvider.notifier).updateApiKey(value),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: state.models.contains(state.settings.model)
                            ? state.settings.model
                            : null,
                        decoration: const InputDecoration(labelText: 'Discovered Model'),
                        items: state.models
                            .map((model) => DropdownMenuItem(value: model, child: Text(model)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          _modelController.text = value;
                          _update(state.settings.copyWith(model: value));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: 'Discover models',
                      onPressed: state.isLoadingModels
                          ? null
                          : () => ref.read(settingsProvider.notifier).discoverModels(),
                      icon: state.isLoadingModels
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Manual Model'),
                  onChanged: (value) => _update(state.settings.copyWith(model: value)),
                ),
                const SizedBox(height: 24),
                Text('Generation', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 110, child: Text('Temperature')),
                    Expanded(
                      child: Slider(
                        value: state.settings.temperature.clamp(0.0, 2.0),
                        min: 0,
                        max: 2,
                        divisions: 20,
                        label: state.settings.temperature.toStringAsFixed(1),
                        onChanged: (value) => _update(state.settings.copyWith(temperature: value)),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(state.settings.temperature.toStringAsFixed(1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxTokensController,
                  decoration: const InputDecoration(labelText: 'Max Tokens'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed == null) return;
                    _update(state.settings.copyWith(maxTokens: parsed));
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: state.settings.visionEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vision model supports images'),
                  onChanged: (value) => _update(state.settings.copyWith(visionEnabled: value)),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                    ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.computer)),
                  ],
                  selected: {state.settings.themeMode},
                  onSelectionChanged: (selection) {
                    _update(state.settings.copyWith(themeMode: selection.first));
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.isTestingConnection
                      ? null
                      : () => ref.read(settingsProvider.notifier).testConnection(),
                  icon: state.isTestingConnection
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cable),
                  label: const Text('Test Connection'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _syncControllers(SettingsState state) {
    void sync(TextEditingController controller, String value) {
      if (controller.text == value) return;
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }

    sync(_endpointController, state.settings.endpointUrl);
    sync(_apiKeyController, state.apiKey);
    sync(_modelController, state.settings.model);
    sync(_maxTokensController, state.settings.maxTokens.toString());
  }

  void _update(AppSettings settings) {
    ref.read(settingsProvider.notifier).updateSettings(settings);
  }
}
