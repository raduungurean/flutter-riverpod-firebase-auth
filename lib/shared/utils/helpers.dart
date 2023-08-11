import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

final Map<ThemeMode, String> themeModeMap = {
  ThemeMode.system: 'System',
  ThemeMode.dark: 'Dark',
  ThemeMode.light: 'Light',
};

final Map<String, ThemeMode> themeModeMapString = {
  'System': ThemeMode.system,
  'Dark': ThemeMode.dark,
  'Light': ThemeMode.light,
};

String getFlexSchemeName(FlexScheme scheme) {
  return scheme.toString().split('.').last;
}

FlexScheme findFlexSchemeByName(String name) {
  return FlexScheme.values.firstWhere(
    (scheme) => getFlexSchemeName(scheme) == name,
    orElse: () => FlexScheme.blueWhale,
  );
}

String formatDisplayName(String displayName) {
  return displayName.replaceAll(RegExp(r'\W'), '').toLowerCase();
}
