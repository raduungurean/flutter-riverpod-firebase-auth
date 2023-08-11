import 'package:firebase_auth/firebase_auth.dart';
import 'package:spendbuddy/features/auth/service/email_service.interface.dart';

class FirebaseEmailService implements EmailVerificationService {
  final FirebaseAuth _firebaseAuth;

  FirebaseEmailService(this._firebaseAuth);

  @override
  Future<void> sendEmailVerification(String uid) async {
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null && firebaseUser.uid == uid) {
      await firebaseUser.sendEmailVerification();
    }
  }

  Future<void> recoverPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
