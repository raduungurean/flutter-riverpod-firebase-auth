import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/auth/presentation/forgot_password_screen.dart';
import 'package:spendbuddy/features/auth/presentation/register_screen.dart';
import 'package:spendbuddy/widgets/async_value_ui.dart';
import 'package:spendbuddy/widgets/base_layout.dart';
import 'package:spendbuddy/widgets/google_signin_button.dart'
    if (dart.library.html) 'package:spendbuddy/widgets/google_signin_web_button.dart';
import 'package:spendbuddy/widgets/rounded_loading_button.dart';
import 'package:spendbuddy/widgets/text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();

  static String get routeName => 'signin';
  static String get routeLocation => '/sign-in';
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.read(routerControllerProvider);
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) => state.showSnackbarOnError(context),
    );
    final state = ref.watch(authControllerProvider);
    return BaseLayout(
      title: null,
      isScrollable: true,
      layoutAuth: true,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            buildStyledTextFormField(
              context: context,
              labelText: 'Email',
              onSaved: (value) => _email = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            buildStyledTextFormField(
              context: context,
              labelText: 'Password',
              onSaved: (value) => _password = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            buildSubmitButton(
              context: context,
              isLoading: state.isLoading,
              formKey: _formKey,
              text: 'Login',
              submit: () => ref
                  .read(authControllerProvider.notifier)
                  .signIn(_email, _password),
            ),
            const SizedBox(
              height: 10,
            ),
            GoogleSignInButton(
              onPressed: () async {
                if (!kIsWeb) {
                  await ref
                      .read(authControllerProvider.notifier)
                      .signInWithGoogle();
                }
              },
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            // ElevatedButton.icon(
            //   icon: Icon(Icons.facebook), // Placeholder icon
            //   label: Text('Sign in with Facebook'),
            //   onPressed: () {
            //     // Implement Facebook sign-in logic here later
            //   },
            // ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    goRouter.go(RegisterScreen.routeLocation);
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    goRouter.go(ForgotPasswordScreen.routeLocation);
                  },
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
