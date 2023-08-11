import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/shared/providers/theme_provider.dart';
import 'package:spendbuddy/shared/utils/helpers.dart';
import 'package:spendbuddy/widgets/SpinLoader.dart';
import 'package:spendbuddy/widgets/base_layout.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static String get routeLocation => '/settings';
  static String get routeName => 'settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    return BaseLayout(
      title: 'Settings',
      body: themeState.when(
        data: (theme) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildThemePrefs(theme, ref),
          );
        },
        error: (_, __) => const Text('An error occurred'),
        loading: () => const SpinLoader(),
      ),
    );
  }
}

Container buildThemePrefs(
  ThemePreferences theme,
  WidgetRef ref,
) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30, // fixed width
              child: Icon(Icons.color_lens), // Icon for Color Scheme
            ),
            Expanded(
              child: DropdownButton<FlexScheme>(
                value: findFlexSchemeByName(theme.schemeName),
                onChanged: (FlexScheme? scheme) async {
                  if (scheme != null) {
                    ref
                        .read(themeNotifierProvider.notifier)
                        .setThemePreferences(
                          getFlexSchemeName(scheme),
                          theme.themeMode,
                        );
                  }
                },
                items: FlexScheme.values.map<DropdownMenuItem<FlexScheme>>(
                  (FlexScheme scheme) {
                    return DropdownMenuItem<FlexScheme>(
                      value: scheme,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(getFlexSchemeName(scheme)),
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(left: 8),
                            color: FlexColor.schemes[scheme]?.light.primary ??
                                Colors.transparent,
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 30, // fixed width
              child: Icon(Icons.brightness_6), // Icon for Theme Mode
            ),
            Expanded(
              child: DropdownButton<ThemeMode>(
                value: themeModeMapString[theme.themeMode],
                onChanged: (ThemeMode? mode) async {
                  if (mode != null) {
                    ref
                        .read(themeNotifierProvider.notifier)
                        .setThemePreferences(
                          theme.schemeName,
                          themeModeMap[mode].toString(),
                        );
                  }
                },
                items: ThemeMode.values.map<DropdownMenuItem<ThemeMode>>(
                  (ThemeMode mode) {
                    return DropdownMenuItem<ThemeMode>(
                      value: mode,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(themeModeMap[mode]!)],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
