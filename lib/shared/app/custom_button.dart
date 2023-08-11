import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class CustomTextButton extends StatelessWidget {
  final String text;
  final ButtonSize size;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
  });

  double get _height {
    switch (size) {
      case ButtonSize.small:
        return 20.0;
      case ButtonSize.medium:
        return 25.0;
      case ButtonSize.large:
        return 30.0;
      default:
        return 25.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 44.0,
            vertical: 0.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              28.0,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
