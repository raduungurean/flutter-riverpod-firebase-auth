abstract class EmailVerificationService {
  Future<void> sendEmailVerification(String uid);
  Future<void> recoverPassword(String email);
}
