import 'package:firebase_auth/firebase_auth.dart';
import 'package:spendbuddy/features/auth/data/user_model.dart';
import 'package:spendbuddy/shared/app/registration_data.dart';

abstract class AuthRepository {
  // Listen to authentication state changes.
  Stream<User?> get authStateChanges;

  // Check if the current user's email is verified.
  bool get isCurrentUserEmailVerified;

  Stream<UserModel?> get userChanges;
  FirebaseAuth get firebaseAuth;
  Future<UserModel?> updateUserDocument(String id, authResult);
  Future<UserModel?> signInWithGoogle();

  // Sign in a user with email and password.
  Future<void> signIn(String email, String password);

  // Create a new user with the given registration data.
  Future<UserModel> createUser(RegistrationData registrationData);

  // Sign out the currently authenticated user.
  Future<void> signOut();

  // Re-authenticate a user using email and current password.
  Future<void> reAuthenticateUser(String email, String currentPassword);

  // Check if a display name is unique.
  Future<bool> isDisplayNameUnique(String displayName, String currentUserId);

  // Delete the account of the currently authenticated user.
  Future<void> deleteAccount();

  // Get a stream to the user's Firestore data.
  Stream<UserModel?> userFirestoreStream(String userId);

  // Get the user model of the currently authenticated user.
  Stream<UserModel?> get getUser;

  // Update a user's model in Firestore.
  Future<void> updateUserModel(UserModel userModel);

  // Update the user's first name, last name, and display name.
  Future<void> updateUser(
    String uid,
    String firstName,
    String lastName,
    String displayName,
  );

  Future<void> changePassword(String newPassword);
}
