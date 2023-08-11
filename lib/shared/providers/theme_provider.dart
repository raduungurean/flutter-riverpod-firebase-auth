import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  final String schemeName;
  final String themeMode;

  ThemePreferences({
    required this.schemeName,
    required this.themeMode,
  });
}

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final themeNotifierProvider =
    StateNotifierProvider<StringStateNotifier, AsyncValue<ThemePreferences>>(
        (ref) {
  return StringStateNotifier(ref.watch(sharedPreferencesProvider.future));
});

class StringStateNotifier extends StateNotifier<AsyncValue<ThemePreferences>> {
  final Future<SharedPreferences> _sharedPreferencesFuture;

  StringStateNotifier(this._sharedPreferencesFuture)
      : super(const AsyncValue.loading()) {
    loadThemePreferences();
  }

  Future<void> loadThemePreferences() async {
    state = const AsyncValue.loading();
    try {
      final sharedPreferences = await _sharedPreferencesFuture;
      final encodedResult =
          sharedPreferences.getString('theme_preferences') ?? '';

      dynamic decodedResult;

      if (encodedResult != '' && encodedResult.startsWith('{')) {
        decodedResult = jsonDecode(encodedResult);
      } else {
        decodedResult = {'schemeName': 'blue', 'themeMode': 'System'};
      }

      final prefs = ThemePreferences(
        schemeName: decodedResult['schemeName'] ?? 'blue',
        themeMode: decodedResult['themeMode'] ?? 'System',
      );

      state = AsyncValue.data(prefs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setThemePreferences(
    String schemeName,
    String themeMode,
  ) async {
    Map<String, String> stringValues = {
      'schemeName': schemeName,
      'themeMode': themeMode,
    };
    final sharedPreferences = await _sharedPreferencesFuture;
    await sharedPreferences.setString(
      'theme_preferences',
      jsonEncode(stringValues),
    );
    loadThemePreferences();
  }
}
