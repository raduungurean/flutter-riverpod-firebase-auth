import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/profile/presentation/password_change_form.dart';
import 'package:spendbuddy/features/profile/presentation/profile_form.dart';
import 'package:spendbuddy/widgets/base_layout.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static String get routeLocation => '/profile';
  static String get routeName => 'profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _deleteAccount() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete the account? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Returns false when cancel is pressed
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.deleteAccountAndData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      isScrollable: true,
      mainAxisAlignment: MainAxisAlignment.start,
      title: 'Profile',
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileForm(),
            const SizedBox(height: 20),
            const PasswordChangeForm(),
            const SizedBox(
              height: 10.0,
            ),
            TextButton(
              onPressed: _deleteAccount,
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
