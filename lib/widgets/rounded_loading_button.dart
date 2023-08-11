import 'package:flutter/material.dart';

Widget buildSubmitButton({
  required BuildContext context,
  required bool isLoading,
  required GlobalKey<FormState> formKey,
  required Function submit,
  required String text,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.5,
    child: ElevatedButton(
      onPressed: isLoading
          ? () {
              print('>>>>> a ${isLoading}');
            }
          : () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                submit();
              } else {
                // check what is the problem specifically ???
                print('>>>>> b ${formKey.currentState}');
              }
            },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
    ),
  );
}
