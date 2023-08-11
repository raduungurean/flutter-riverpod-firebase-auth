import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spendbuddy/app/app_router.dart';
import 'package:spendbuddy/features/auth/auth_exception.dart';
import 'package:spendbuddy/features/auth/data/auth_repository.interface.dart';
import 'package:spendbuddy/features/auth/data/user_model.dart';
import 'package:spendbuddy/features/auth/providers.dart';
import 'package:spendbuddy/features/auth/service/email_service.interface.dart';
import 'package:spendbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:spendbuddy/shared/app/registration_data.dart';
import 'package:spendbuddy/shared/controllers/success_snackbar.controller.dart';
import 'package:spendbuddy/shared/providers/firebase_image_storage_provider.dart';
import 'package:spendbuddy/shared/providers/google_sing_in_provider.dart';
import 'package:spendbuddy/shared/providers/snackbar_provider.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    snackbarController: ref.read(snackbarControllerProvider),
    emailService: ref.read(emailVerificationServiceProvider),
    imageStorageService: ref.read(imageStorageServiceProvider),
    goRouter: ref.read(routerControllerProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository authRepository;
  final SnackbarController snackbarController;
  final EmailVerificationService emailService;
  final ImageStorageService imageStorageService;
  final GoogleSignIn googleSignIn;
  final goRouter;
  late StreamSubscription<UserModel?>? _userModelSubscription;

  AuthController({
    required this.authRepository,
    required this.snackbarController,
    required this.emailService,
    required this.imageStorageService,
    required this.goRouter,
    required this.googleSignIn,
  }) : super(const AsyncLoading()) {
    _handleUserChange();

    if (kIsWeb) {
      // also make a subscription to this
      // on sign out unsubscribe
      googleSignIn.onCurrentUserChanged
          .listen((GoogleSignInAccount? account) async {
        print('>>>>> listen here');
        if (account != null) {
          final GoogleSignInAuthentication googleAuth =
              await account.authentication;

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential authResult = await authRepository.firebaseAuth
              .signInWithCredential(credential);

          // Update the user details in Firestore or create a new document if it doesn't exist
          // this will emit and the ui will update
          // Fetch the current user data from Firestore

          if (authResult.user != null) {
            await authRepository.updateUserDocument(
                authResult.user!.uid, authResult);
            await goRouter.go(DashboardScreen.routeLocation);
          }
        } else {
          // User signed out or some error occurred
          print('User signed out');
        }
      });

      googleSignIn.signInSilently();
    }
  }

  void _handleUserChange() {
    _userModelSubscription =
        authRepository.userChanges.listen((UserModel? user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await authRepository.signOut();
    state = const AsyncData(null);
    await goRouter.go(DashboardScreen.routeLocation);
  }

  Future<void> signIn(String emailAddress, String password) async {
    state = const AsyncValue.loading();
    try {
      await authRepository.signIn(emailAddress, password);
      // this is being take care of in the constructor
      // the new state comes from there
      // state = AsyncData(user);
      await goRouter.go(DashboardScreen.routeLocation);
    } on AuthException catch (e, st) {
      state = AsyncError(e, StackTrace.empty);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final UserModel? user = await authRepository.signInWithGoogle();
      if (user != null) {
        // this is being take care of in the constructor
        // the new state comes from there
        // state = AsyncData(user);
        await goRouter.go(DashboardScreen.routeLocation);
      } else {
        state = const AsyncValue.error(
          "Failed to sign in with Google",
          StackTrace.empty,
        );
        // any async error is displayed in snackbar already
        // see async_value_ui
        // snackbarController.showErrorMessage('Failed to sign in with Google');
      }
    } catch (error) {
      state = AsyncValue.error(error.toString(), StackTrace.empty);
      // snackbarController.showErrorMessage(error.toString());
    }
  }

  Future<void> createUser(RegistrationData registrationData) async {
    state = const AsyncValue.loading();
    try {
      UserModel userCredential =
          await authRepository.createUser(registrationData);

      emailService.sendEmailVerification(userCredential.id);
      state = AsyncData(userCredential);
      await goRouter.go(DashboardScreen.routeLocation);
    } on AuthException catch (e, st) {
      state = AsyncError(e, StackTrace.empty);
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      await emailService.recoverPassword(email);
      snackbarController.showSuccessMessage(
        'Password reset email sent. Please check your email to reset your password.',
      );
    } catch (e) {
      snackbarController.showErrorMessage(
        'Error sending password reset email. Please try again later.',
      );
    }
  }

  Future<void> resendActivationEmail() async {
    if (state is AsyncData<UserModel?> &&
        (state as AsyncData<UserModel?>).value != null) {
      final userId = (state as AsyncData<UserModel?>).value!.id;

      try {
        await emailService.sendEmailVerification(userId);
        snackbarController.showSuccessMessage(
          'Activation email resent. Please check your email to verify your account.',
        );
      } catch (e) {
        snackbarController.showErrorMessage(
          'Error resending activation email. Please try again later.',
        );
      }
    } else {
      snackbarController.showErrorMessage(
        'No user is currently signed in.',
      );
    }
  }

  Future<void> updateUserPhoto(File imageFile, Uint8List bytes) async {
    try {
      String imageUrl = '';

      if (kIsWeb) {
        imageUrl = await imageStorageService.uploadUserImageBytes(
          state.value!.id,
          bytes,
        );
      } else {
        imageUrl = await imageStorageService.uploadUserImage(
          state.value!.id,
          imageFile,
        );
      }

      await authRepository.updateUserModel(
        state.value!.copyWith(photoURL: imageUrl),
      );

      state = AsyncData(state.value!.copyWith(photoURL: imageUrl));
    } catch (e) {
      // show an error here
    }
  }

  Future<void> updateUserPassword(
    String newPassword,
    String currentPassword,
  ) async {
    if (state is AsyncData<UserModel?> &&
        (state as AsyncData<UserModel?>).value != null) {
      try {
        String userEmail = (state as AsyncData<UserModel?>).value!.email;
        await authRepository.reAuthenticateUser(userEmail, currentPassword);

        await authRepository.changePassword(newPassword);
        snackbarController.showSuccessMessage('Password updated successfully');
      } catch (error) {
        snackbarController.showErrorMessage(error.toString());
      }
    } else {
      snackbarController.showErrorMessage('No user signed in');
    }
  }

  Future<void> updateUser(
    String firstName,
    String lastName,
    String displayName,
  ) async {
    try {
      if (state is AsyncData<UserModel?> &&
          (state as AsyncData<UserModel?>).value != null) {
        final userId = (state as AsyncData<UserModel?>).value!.id;

        bool isUnique = await authRepository.isDisplayNameUnique(
          displayName,
          userId,
        );

        if (!isUnique) {
          snackbarController
              .showErrorMessage('The display name is already taken');
          return;
        }

        await authRepository.updateUser(
          userId,
          firstName,
          lastName,
          displayName,
        );

        snackbarController.showSuccessMessage(
          'User information updated successfully.',
        );
      } else {
        snackbarController.showErrorMessage('User not found.');
      }
    } catch (e) {
      snackbarController.showErrorMessage(
        'Error updating user information. Please try again later.',
      );
    }
  }

  Future<void> deleteAccountAndData() async {
    if (state is AsyncData<UserModel?> &&
        (state as AsyncData<UserModel?>).value != null) {
      // final userId = (state as AsyncData<UserModel?>).value!.id;
      //
      // final storageReference = _storage.ref().child(user.uid);
      //
      // await storageReference.listAll().then((dir) {
      //   dir.items.forEach((item) {
      //     item.delete();
      //   });
      // });

      try {
        state = const AsyncData(null);
        await authRepository.deleteAccount();
        await goRouter.go(DashboardScreen.routeLocation);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _userModelSubscription!.cancel();
    super.dispose();
  }
}
