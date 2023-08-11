import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_screen.dart';
import 'package:spendbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:spendbuddy/features/auth/presentation/forgot_password_screen.dart';
import 'package:spendbuddy/features/auth/presentation/register_screen.dart';
import 'package:spendbuddy/features/profile/presentation/profile_screen.dart';
import 'package:spendbuddy/features/settings/presentation/settings_screen.dart';
import 'package:spendbuddy/shared/initial_location.dart'
    if (dart.library.html) 'package:spendbuddy/shared/initial_location.web.dart';

bool debugEnabled = false;

final _key = GlobalKey<NavigatorState>();

final routerControllerProvider = Provider.autoDispose<GoRouter>((ref) {
  return _createGoRouter(ref);
});

GoRouter _createGoRouter(ref) {
  print('<<<<< init router');

  return GoRouter(
    debugLogDiagnostics: debugEnabled,
    initialLocation: initialLocation,
    navigatorKey: _key,
    routes: [
      GoRoute(
        path: DashboardScreen.routeLocation,
        name: DashboardScreen.routeName,
        builder: (context, state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: AuthScreen.routeLocation,
        name: AuthScreen.routeName,
        builder: (context, state) {
          return const AuthScreen();
        },
        redirect: (context, state) {},
      ),
      GoRoute(
        path: RegisterScreen.routeLocation,
        name: RegisterScreen.routeName,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: ForgotPasswordScreen.routeLocation,
        name: ForgotPasswordScreen.routeName,
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: SettingsScreen.routeLocation,
        name: SettingsScreen.routeName,
        builder: (context, state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: ProfileScreen.routeLocation,
        name: ProfileScreen.routeName,
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),
    ],
    redirect: (context, state) {
      return getRedirect(state, ref);
    },
    observers: [],
  );
}

Future<String?> getRedirect(GoRouterState state, ref) async {
  return null;

  // print('>>>> ${FirebaseAuth.instance.currentUser}');

  // final authController = ref.watch(authControllerProvider);

  // final authController = ref.watch(authControllerProvider);
  //
  // if (authController is AsyncLoading) {
  //   print('[redirect] state loading redirect: null - ${state.location}');
  //   return null;
  // }
  //
  // if (authController is AsyncError) {
  //   if (debugEnabled)
  //     print('[redirect] state error redirect: null - ${state.location}');
  //   return null;
  // }
  //
  // final user = (authController as AsyncData<UserModel?>).value;
  // final isAuthenticated = user != null;

  // if (debugEnabled)
  //   print(
  //     '[redirect] GoRouter redirect called. Current state: ${state.location} - ${isAuthenticated}',
  //   );
  //
  // final isSplash = state.location == SplashPage.routeLocation;
  // if (isSplash) {
  //   final target = isAuthenticated
  //       ? DashboardScreen.routeLocation
  //       : AuthScreen.routeLocation;
  //   if (debugEnabled)
  //     print('[redirect] Splash page detected. Redirecting to: $target');
  //   return target;
  // }
  //
  // final isLoggingIn = state.location == AuthScreen.routeLocation;
  //
  // if (isLoggingIn) {
  //   final target = isAuthenticated ? DashboardScreen.routeLocation : null;
  //   if (debugEnabled)
  //     print('[redirect] Logging in detected. Redirecting to: $target');
  //   return target;
  // }
  //
  // final isRegistering = state.location == RegisterScreen.routeLocation;
  // final isResettingPassword =
  //     state.location == ForgotPasswordScreen.routeLocation;
  //
  // if (isRegistering || isResettingPassword) {
  //   if (debugEnabled)
  //     print('[redirect] Registration or password reset detected. No redirect.');
  //   return null;
  // }
  //
  // final target = isAuthenticated ? null : SplashPage.routeLocation;
  // if (debugEnabled) print('[redirect] Redirecting to: $target');
  //
  // return target;
}
