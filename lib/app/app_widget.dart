import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/shared/providers/theme_provider.dart';
import 'package:spendbuddy/shared/utils/helpers.dart';
import 'package:spendbuddy/widgets/SpinLoader.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<App> createState() => _App();
}

class _App extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerControllerProvider);
    final themeState = ref.watch(themeNotifierProvider);

    return themeState.when(
      data: (themePrefs) {
        FlexScheme scheme = findFlexSchemeByName(themePrefs.schemeName);
        ThemeMode mode =
            themeModeMapString[themePrefs.themeMode] ?? ThemeMode.system;
        return MaterialApp.router(
          title: 'Flavius App',
          key: navigatorKey,
          theme: FlexColorScheme.light(
            scheme: scheme,
            textTheme: GoogleFonts.blinkerTextTheme(
              Theme.of(context).textTheme,
            ),
          ).toTheme,
          darkTheme: FlexColorScheme.dark(
            scheme: scheme,
            textTheme: GoogleFonts.blinkerTextTheme(
              Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            ),
          ).toTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
      loading: () => const Directionality(
        textDirection: TextDirection.ltr,
        child: SpinLoader(),
      ),
      error: (_, __) {
        return const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Text('An error occurred 1'),
          ),
        );
      },
    );
  }
}
