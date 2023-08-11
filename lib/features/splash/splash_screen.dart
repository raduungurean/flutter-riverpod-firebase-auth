import 'package:flutter/material.dart';
import 'package:spendbuddy/widgets/SpinLoader.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);
  static String get routeName => 'splash';
  static String get routeLocation => '/';

  @override
  Widget build(BuildContext context) {
    return const SpinLoader();
  }
}
