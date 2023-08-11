import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spendbuddy/features/auth/data/auth_repository.interface.dart';
import 'package:spendbuddy/features/auth/auth_exception.dart';
import 'package:spendbuddy/features/auth/data/user_model.dart';
import 'package:spendbuddy/shared/app/registration_data.dart';
import 'package:spendbuddy/shared/utils/helpers.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn googleSignIn;
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreUserSubscription;

  FirebaseAuthRepository(this._firebaseAuth, this.googleSignIn) {
    _initStreams();
  }

  void _initStreams() {
    _authStateSubscription = authStateChanges.listen((user) {
      if (user != null) {
        _updateUserFromFirestore(user.uid);

        _firestoreUserSubscription?.cancel();
        _firestoreUserSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            UserModel userModel = UserModel(
              id: user.uid,
              firstName: snapshot.data()?['firstName'] ?? "",
              lastName: snapshot.data()?['lastName'] ?? "",
              email: snapshot.data()?['email'] ?? "",
              emailVerified: snapshot.data()?['emailVerified'] ?? false,
              displayName: snapshot.data()?['displayName'],
              photoURL: snapshot.data()?['photoURL'],
            );
            _userStreamController.add(userModel);
          } else {
            _userStreamController.add(null);
          }
        });
      } else {
        _firestoreUserSubscription?.cancel();
        _userStreamController.add(null);
      }
    });
  }

  Future<void> _updateUserFromFirestore(String uid) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      UserModel userModel = UserModel(
        id: uid,
        firstName: data['firstName'] ?? "",
        lastName: data['lastName'] ?? "",
        email: data['email'] ?? "",
        emailVerified: data['emailVerified'] ?? false,
        displayName: data['displayName'],
        photoURL: data['photoURL'],
      );
      _userStreamController.add(userModel);
    }
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _firestoreUserSubscription?.cancel();
    _userStreamController.close();
  }

  @override
  Stream<UserModel?> get userChanges => _userStreamController.stream;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  FirebaseAuth get firebaseAuth => _firebaseAuth;

  @override
  Future<UserModel> signIn(String emailAddress, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        // Set this later after fetching from Firestore or other sources.
        firstName: "",
        lastName: "",
        email: userCredential.user!.email!,
        emailVerified: userCredential.user!.emailVerified,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      String friendlyMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
        case 'wrong-password':
          friendlyMessage = 'Invalid username or password.';
          break;
        case 'email-already-in-use':
          friendlyMessage = 'The email address is already in use.';
          break;
        default:
          friendlyMessage = 'Sign in failed. Please try again later.';
          break;
      }
      throw AuthException(friendlyMessage);
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _firebaseAuth.signInWithCredential(credential);

        // Update the user details in Firestore or create a new document if it doesn't exist
        // this will emit and the ui will update
        // Fetch the current user data from Firestore
        return await updateUserDocument(authResult.user!.uid, authResult);
      }
    } catch (error) {
      print('>>>> error $error');
      rethrow;
    }

    return null;
  }

  @override
  Future<UserModel?> updateUserDocument(String id, authResult) async {
    final User? user = authResult.user;

    UserModel userModel = UserModel(
      id: user!.uid,
      // Set this later after fetching from Firestore or other sources.
      firstName: "",
      lastName: "",
      email: user.email!,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );

    final userRef = FirebaseFirestore.instance.collection('users').doc(id);
    DocumentSnapshot currentUserSnapshot = await userRef.get();

    if (!currentUserSnapshot.exists) {
      await userRef.set({
        'emailVerified': userModel.emailVerified,
        'displayName': userModel.displayName,
        'photoURL': userModel.photoURL,
        'email': userModel.email,
        'lastSignInDate': Timestamp.now(),
      });
    } else {
      Map<String, dynamic> updateData = {
        'lastSignInDate': Timestamp.now(),
      };

      Map<String, dynamic> currentData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      if (currentData['emailVerified'] == null ||
          !(currentData['emailVerified'] as bool)) {
        updateData['emailVerified'] = userModel.emailVerified;
      }

      if (currentData['displayName'] == null ||
          currentData['displayName'] == '') {
        updateData['displayName'] = userModel.displayName;
      }

      if (currentData['photoURL'] == null || currentData['photoURL'] == '') {
        updateData['photoURL'] = userModel.photoURL;
      }

      if (currentData['email'] == null || currentData['email'] == '') {
        updateData['email'] = userModel.email;
      }

      await userRef.update(updateData);
    }

    return userModel;
  }

  @override
  Future<UserModel> createUser(RegistrationData registrationData) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: registrationData.email,
        password: registrationData.password,
      );

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.doc(userCredential.user!.uid).set({
        'firstName': registrationData.firstName,
        'lastName': registrationData.lastName,
        'email': registrationData.email,
      });

      UserModel user = UserModel(
        id: userCredential.user!.uid,
        firstName: registrationData.firstName,
        lastName: registrationData.lastName,
        email: userCredential.user!.email!,
        emailVerified: userCredential.user!.emailVerified,
        displayName: null,
        photoURL: null,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      String friendlyMessage;
      switch (e.code) {
        case 'email-already-in-use':
          friendlyMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          friendlyMessage = 'The provided email is invalid.';
          break;
        case 'operation-not-allowed':
          friendlyMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          friendlyMessage = 'The password is too weak.';
          break;
        default:
          friendlyMessage = 'Registration failed. Please try again later.';
          break;
      }
      throw AuthException(friendlyMessage);
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateUser(
    String uid,
    String firstName,
    String lastName,
    String displayName,
  ) async {
    User? user = _firebaseAuth.currentUser;

    await user?.updateDisplayName(displayName);
    await user?.reload();

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users.doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
    });
  }

  @override
  Future<void> updateUserModel(UserModel updatedUser) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(updatedUser.id);

    return userRef.set(
      updatedUser.toJson(),
      SetOptions(merge: true),
    );
  }

  @override
  Stream<UserModel?> get getUser {
    return _firebaseAuth.authStateChanges().asyncMap((user) {
      if (user != null) {
        return userFirestoreStream(user.uid).first;
      }
      return Future.value(null);
    });
  }

  // userSream
  // create this method that listens to both
  // 1. emits a new userModel when authStateChanges
  // 2. emits a new userModel when anything inside users collection gets changed
  // advise when and how to unsubscribe
  // I'm supposed to be using this in authcontroller constructor
  // avoid using rxdart
  // a new emission when username changes in users collection
  // a new emission when the user gets sign in signed out with / without google

  @override
  Stream<UserModel?> userFirestoreStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;

      return UserModel(
        id: uid,
        firstName: snapshot.data()?['firstName'] ?? "",
        lastName: snapshot.data()?['lastName'] ?? "",
        email: snapshot.data()?['email'] ?? "",
        emailVerified: snapshot.data()?['emailVerified'] ?? false,
        displayName: snapshot.data()?['displayName'],
        photoURL: snapshot.data()?['photoURL'],
      );
    });
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();
    }
  }

  @override
  bool get isCurrentUserEmailVerified {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser?.emailVerified ?? false;
  }

  @override
  Future<bool> isDisplayNameUnique(
    String displayName,
    String currentUserId,
  ) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    QuerySnapshot queryResult = await usersCollection
        .where('displayName', isEqualTo: formatDisplayName(displayName))
        .get();

    if (queryResult.docs.isEmpty) {
      return true;
    }

    if (queryResult.docs.length == 1 &&
        queryResult.docs.first.id == currentUserId) {
      return true;
    }

    return false;
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user signed in');
    }

    try {
      await currentUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      String friendlyMessage;

      switch (e.code) {
        case 'requires-recent-login':
          friendlyMessage =
              'The user must reauthenticate before this operation.';
          break;
        case 'user-disabled':
          friendlyMessage = 'The user has been disabled.';
          break;
        case 'user-not-found':
          friendlyMessage = 'The user does not exist.';
          break;
        case 'weak-password':
          friendlyMessage = 'The password is too weak.';
          break;
        default:
          friendlyMessage = 'Password update failed. Please try again later.';
          break;
      }

      throw AuthException(friendlyMessage);
    }
  }

  @override
  Future<void> reAuthenticateUser(String email, String currentPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }
}
