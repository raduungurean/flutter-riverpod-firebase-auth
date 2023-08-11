import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/providers.dart';
import 'package:spendbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:spendbuddy/features/settings/presentation/settings_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final goRouter = ref.read(routerControllerProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.blue),
                SizedBox(height: 8),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              goRouter.go(DashboardScreen.routeLocation);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              goRouter.go(SettingsScreen.routeLocation);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await authRepo.signOut();
            },
          ),
        ],
      ),
    );
  }
}
