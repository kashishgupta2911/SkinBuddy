import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _createOrMergeUserProfile(
      uid: credential.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      includeCreatedAt: true,
    );

    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      final names = _splitName(user.displayName ?? '');

      await _createOrMergeUserProfile(
        uid: user.uid,
        firstName: names.$1,
        lastName: names.$2,
        email: user.email ?? '',
        includeCreatedAt:
        userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createOrMergeUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required bool includeCreatedAt,
  }) async {
    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim(),
    };

    if (includeCreatedAt) {
      payload['created_at'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('users').doc(uid).set(
      payload,
      SetOptions(merge: true),
    );
  }

  (String, String) _splitName(String displayName) {
    final trimmed = displayName.trim();

    if (trimmed.isEmpty) {
      return ('', '');
    }

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (
    parts.first,
    parts.sublist(1).join(' '),
    );
  }
}