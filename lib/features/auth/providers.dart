import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendbuddy/features/auth/data/auth_repository.firebase.dart';
import 'package:spendbuddy/features/auth/service/email_service.interface.dart';
import 'package:spendbuddy/features/auth/service/email_service_firebase.dart';
import 'package:spendbuddy/shared/providers/firebase_providers.dart';
import 'package:spendbuddy/shared/providers/google_sing_in_provider.dart';

final emailVerificationServiceProvider = Provider<EmailVerificationService>(
  (ref) => FirebaseEmailService(FirebaseAuth.instance),
);

final authRepositoryProvider = Provider<FirebaseAuthRepository>(
  (ref) => FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.read(googleSignInProvider),
  ),
);
