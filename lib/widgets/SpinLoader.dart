import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spendbuddy/widgets/base_layout.dart';

class SpinLoader extends StatelessWidget {
  final Color? color;

  const SpinLoader({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('splash screen'),
          SpinKitCircle(
            color: color ?? Theme.of(context).colorScheme.primary,
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
