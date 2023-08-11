import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/features/auth/presentation/auth_controller.dart';
import 'package:spendbuddy/shared/app/custom_button.dart';
import 'package:spendbuddy/shared/app/sticky_header.dart';
import 'package:spendbuddy/widgets/SpinLoader.dart';
import 'package:spendbuddy/widgets/base_layout.dart';
import 'package:spendbuddy/widgets/interactive_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static String get routeLocation => '/dashboard';
  static String get routeName => 'dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    final isEmailNotVerified = authController.value?.emailVerified == false;

    if (authController.isLoading) {
      return const SpinLoader();
    }

    final List<Widget> cardContents = List.generate(
      50,
      (index) => InteractiveCard(
        child: Text('Card Content $index'),
      ),
    );

    return BaseLayout(
      title: 'Flavius App',
      isScrollable: false,
      mainAxisAlignment: MainAxisAlignment.start,
      body: CustomStickyHeader(
        isEmpty: !isEmailNotVerified,
        color: Colors.amberAccent,
        items: cardContents,
        headerHeight: 150.0,
        stickyContent: isEmailNotVerified
            ? Container(
                alignment: AlignmentDirectional.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Please activate your account by clicking the link sent to your email.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26.0),
                    const Text(
                      "Missed the activation email or can't find it? Click below to send it again.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    CustomTextButton(
                      text: 'Resend Email',
                      size: ButtonSize.small,
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .resendActivationEmail();
                      },
                    ),
                  ],
                ),
              )
            : Container(),
        content: ListView.builder(
          itemCount: cardContents.length,
          itemBuilder: (context, index) {
            return cardContents[index];
          },
        ),
      ),
    );
  }
}
