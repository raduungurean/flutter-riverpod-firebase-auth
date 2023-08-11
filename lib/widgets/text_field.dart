import 'package:flutter/material.dart';

TextFormField buildStyledTextFormField({
  required BuildContext context,
  required String labelText,
  required Function(String?) onSaved,
  required String? Function(String?) validator,
  bool obscureText = false,
}) {
  InputDecoration decoration = InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Theme.of(context).canvasColor,
      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.inversePrimary,
          width: 4.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.inversePrimary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2.0,
        ),
      ));

  return TextFormField(
    decoration: decoration,
    obscureText: obscureText,
    validator: validator,
    onSaved: onSaved,
  );
}
