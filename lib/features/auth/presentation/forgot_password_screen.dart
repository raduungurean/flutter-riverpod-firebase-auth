import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/auth/presentation/auth_screen.dart';
import 'package:spendbuddy/widgets/base_layout.dart';
import 'package:spendbuddy/widgets/rounded_loading_button.dart';
import 'package:spendbuddy/widgets/text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  static String get routeLocation => '/forgot-password';
  static String get routeName => 'forgotpassword';

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.read(routerControllerProvider);
    return BaseLayout(
      title: null,
      isScrollable: true,
      layoutAuth: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                'Forgot password?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              buildSubmitButton(
                context: context,
                isLoading: false,
                formKey: _formKey,
                text: 'Submit',
                submit: () {
                  return ref
                      .read(authControllerProvider.notifier)
                      .recoverPassword(_email);
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  goRouter.go(AuthScreen.routeLocation);
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
