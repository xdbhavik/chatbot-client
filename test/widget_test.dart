import 'package:chatbot_app/app/app.dart';
import 'package:chatbot_app/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LM Studio chat app launches with chat input and settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const LmStudioChatApp(),
      ),
    );
    await tester.pump();

    expect(find.text('LM Studio Chat'), findsWidgets);
    expect(find.text('Message LM Studio...'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Endpoint URL'), findsOneWidget);
    expect(find.text('API Key'), findsOneWidget);
  });
}
