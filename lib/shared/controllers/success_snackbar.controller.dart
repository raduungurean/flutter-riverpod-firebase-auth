import 'package:flutter/material.dart';

enum SnackbarMessageType { success, error }

class SnackbarMessage {
  final String message;
  final SnackbarMessageType type;

  SnackbarMessage({
    required this.message,
    required this.type,
  });
}

class SnackbarController extends ChangeNotifier {
  SnackbarMessage? _currentMessage;
  SnackbarMessage? get currentMessage => _currentMessage;

  void showSuccessMessage(String message) {
    _currentMessage = SnackbarMessage(
      message: message,
      type: SnackbarMessageType.success,
    );
    notifyListeners();
  }

  void showErrorMessage(String message) {
    _currentMessage = SnackbarMessage(
      message: message,
      type: SnackbarMessageType.error,
    );
    notifyListeners();
  }

  void hideMessage() {
    _currentMessage = null;
    notifyListeners();
  }
}
