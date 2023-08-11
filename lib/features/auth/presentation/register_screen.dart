import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/features/auth/presentation/auth_screen.dart';
import 'package:spendbuddy/shared/app/registration_data.dart';
import 'package:spendbuddy/widgets/async_value_ui.dart';
import 'package:spendbuddy/widgets/base_layout.dart';
import 'package:spendbuddy/widgets/rounded_loading_button.dart';
import 'package:spendbuddy/widgets/text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static String get routeLocation => '/register';
  static String get routeName => 'register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _password = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.read(routerControllerProvider);

    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) => state.showSnackbarOnError(context),
    );

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
              Text(
                'Register',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              buildStyledTextFormField(
                context: context,
                labelText: 'First Name',
                onSaved: (value) => _firstName = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              buildStyledTextFormField(
                context: context,
                labelText: 'Last Name',
                onSaved: (value) => _lastName = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              buildStyledTextFormField(
                context: context,
                labelText: 'Confirm Password',
                onSaved: (value) => _confirmPassword = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  final form = _formKey.currentState;
                  if (form != null) {
                    form.save();
                    if (_password != value) {
                      return 'Passwords do not match';
                    }
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 20),
              buildSubmitButton(
                context: context,
                isLoading: false,
                formKey: _formKey,
                text: 'Register',
                submit: () {
                  final registrationData = RegistrationData(
                    email: _email,
                    firstName: _firstName,
                    lastName: _lastName,
                    password: _password,
                    confirmPassword: _confirmPassword,
                  );

                  return ref
                      .read(authControllerProvider.notifier)
                      .createUser(registrationData);
                },
              ),
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
