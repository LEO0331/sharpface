import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'phoneNumber': phoneNumber,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return credential;
  }

  Stream<AppUser?> watchCurrentAppUser() {
    return authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final role = doc.data()?['role'] as String?;
    return role == 'admin';
  }

  Future<void> signOut() => _auth.signOut();

  String? _guestVerificationId;
  int? _guestResendToken;

  Future<void> sendGuestPhoneOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(String message) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _guestResendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final result = await _auth.signInWithCredential(credential);
        await _writeGuestVerificationAudit(result.user?.uid, phoneNumber);
        await _auth.signOut();
      },
      verificationFailed: (FirebaseAuthException e) {
        onFailed(e.message ?? 'OTP verification failed.');
      },
      codeSent: (String verificationId, int? resendToken) {
        _guestVerificationId = verificationId;
        _guestResendToken = resendToken;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _guestVerificationId = verificationId;
      },
    );
  }

  Future<bool> verifyGuestPhoneOtp({
    required String phoneNumber,
    required String smsCode,
  }) async {
    final verificationId = _guestVerificationId;
    if (verificationId == null) return false;

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      final result = await _auth.signInWithCredential(credential);
      await _writeGuestVerificationAudit(result.user?.uid, phoneNumber);
      await _auth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _writeGuestVerificationAudit(String? uid, String phoneNumber) async {
    await _firestore.collection('guestVerifications').add({
      'uid': uid,
      'phoneNumber': phoneNumber,
      'verifiedAt': FieldValue.serverTimestamp(),
      'channel': 'firebase_phone_otp',
      'usedForScan': true,
    });
  }
}
