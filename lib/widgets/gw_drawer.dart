import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/drawer/gf_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/auth/presentation/auth_screen.dart';
import 'package:spendbuddy/features/auth/presentation/forgot_password_screen.dart';
import 'package:spendbuddy/features/auth/presentation/register_screen.dart';
import 'package:spendbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:spendbuddy/features/profile/presentation/profile_screen.dart';
import 'package:spendbuddy/features/settings/presentation/settings_screen.dart';

class GWDrawer extends ConsumerWidget {
  const GWDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final goRouter = ref.read(routerControllerProvider);

    // Get the user name and email.
    String userName = authState.maybeWhen(
      data: (user) => user?.displayName ?? '',
      orElse: () => '',
    );
    String userEmail = authState.maybeWhen(
      data: (user) => user?.email ?? '',
      orElse: () => '',
    );
    String photoURL = authState.maybeWhen(
      data: (user) => user?.photoURL ?? '',
      orElse: () => '',
    );
    bool isAuthenticated = authState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );

    List<Widget> unauthenticatedItems = [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.login),
        title: const Text('Login', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(AuthScreen.routeLocation);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.app_registration),
        title: const Text('Register', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(RegisterScreen.routeLocation);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.lock_open),
        title: const Text('Forgot Password', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(ForgotPasswordScreen.routeLocation);
        },
      ),
    ];

    List<Widget> authenticatedItems = [
      Container(
        height: 280,
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: GFAvatar(
                  backgroundImage: NetworkImage(photoURL),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.home),
        title: const Text('Home', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(DashboardScreen.routeLocation);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.settings),
        title: const Text('Settings', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(SettingsScreen.routeLocation);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.account_circle),
        title: const Text('Profile', style: TextStyle(fontSize: 20)),
        onTap: () {
          goRouter.go(ProfileScreen.routeLocation);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: const Icon(Icons.logout),
        title: const Text('Logout', style: TextStyle(fontSize: 20)),
        onTap: () async {
          ref.read(authControllerProvider.notifier).signOut();
        },
      ),
    ];

    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: isAuthenticated ? authenticatedItems : unauthenticatedItems,
      ),
    );
  }
}
