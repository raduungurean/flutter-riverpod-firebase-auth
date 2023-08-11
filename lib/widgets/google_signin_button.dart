import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.black,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      icon: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.blue, size: 14.0), // Blue dot
          SizedBox(width: 2.0),
          Icon(Icons.circle, color: Colors.red, size: 14.0), // Red dot
          SizedBox(width: 2.0),
          Icon(Icons.circle, color: Colors.yellow, size: 14.0), // Yellow dot
          SizedBox(width: 2.0),
          Icon(Icons.circle, color: Colors.green, size: 14.0), // Green dot
        ],
      ),
      label: Text(
        'Sign in with Google',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
