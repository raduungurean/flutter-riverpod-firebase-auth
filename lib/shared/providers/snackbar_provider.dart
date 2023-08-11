import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/shared/controllers/success_snackbar.controller.dart';

final snackbarProvider = ChangeNotifierProvider<SnackbarController>((ref) {
  return SnackbarController();
});

final snackbarControllerProvider = Provider<SnackbarController>((ref) {
  return ref.watch(snackbarProvider);
});
