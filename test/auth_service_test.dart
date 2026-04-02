import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test(
      'registerWithEmailPassword creates users doc with role user',
      () async {
        final firestore = FakeFirebaseFirestore();
        final auth = MockFirebaseAuth();
        final service = AuthService(auth: auth, firestore: firestore);

        final credential = await service.registerWithEmailPassword(
          email: 'new@example.com',
          password: '123456',
          phoneNumber: '+886900000001',
        );

        final uid = credential.user!.uid;
        final doc = await firestore.collection('users').doc(uid).get();
        expect(doc.exists, true);
        expect(doc.data()?['email'], 'new@example.com');
        expect(doc.data()?['role'], 'user');
        expect(doc.data()?['phoneNumber'], '+886900000001');
      },
    );

    test('isAdmin returns true when user role is admin', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('admin-1').set({
        'email': 'admin@example.com',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final service = AuthService(
        auth: MockFirebaseAuth(),
        firestore: firestore,
      );
      final result = await service.isAdmin('admin-1');
      expect(result, true);
    });

    test('isAdmin returns false when role is missing', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('u2').set({
        'email': 'u2@example.com',
      });

      final service = AuthService(
        auth: MockFirebaseAuth(),
        firestore: firestore,
      );
      final result = await service.isAdmin('u2');
      expect(result, false);
    });

    test('watchCurrentAppUser emits signed-in app user', () async {
      final firestore = FakeFirebaseFirestore();
      const uid = 'user-123';
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: uid, email: 'u@example.com'),
        signedIn: true,
      );

      await firestore.collection('users').doc(uid).set({
        'email': 'u@example.com',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final service = AuthService(auth: auth, firestore: firestore);
      final user = await service.watchCurrentAppUser().first;

      expect(user, isNotNull);
      expect(user!.id, uid);
      expect(user.email, 'u@example.com');
      expect(user.role, 'user');
    });

    test('signInWithEmailPassword works for existing mock user', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'a@example.com'),
        signedIn: false,
      );
      await auth.createUserWithEmailAndPassword(
        email: 'a@example.com',
        password: '123456',
      );
      await auth.signOut();

      final service = AuthService(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
      );
      final credential = await service.signInWithEmailPassword(
        email: 'a@example.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'a@example.com');
      expect(auth.currentUser, isNotNull);
    });

    test('watchCurrentAppUser emits null when profile doc missing', () async {
      const uid = 'missing-profile-user';
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: uid, email: 'missing@example.com'),
        signedIn: true,
      );
      final service = AuthService(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      final appUser = await service.watchCurrentAppUser().first;
      expect(appUser, isNull);
    });

    test('signOut clears current user', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u3', email: 'u3@example.com'),
        signedIn: true,
      );
      final service = AuthService(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      await service.signOut();
      expect(auth.currentUser, isNull);
    });

    test(
      'verifyGuestPhoneOtp returns false before verification id exists',
      () async {
        final service = AuthService(
          auth: MockFirebaseAuth(),
          firestore: FakeFirebaseFirestore(),
        );
        final ok = await service.verifyGuestPhoneOtp(
          phoneNumber: '+886900000002',
          smsCode: '123456',
        );
        expect(ok, false);
      },
    );

    test('guest otp flow writes verification audit on success', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth();
      final service = AuthService(auth: auth, firestore: firestore);

      var codeSent = false;
      var failed = false;
      await service.sendGuestPhoneOtp(
        phoneNumber: '+886900000003',
        onCodeSent: () => codeSent = true,
        onFailed: (_) => failed = true,
      );

      expect(codeSent, isTrue);
      expect(failed, isFalse);

      final ok = await service.verifyGuestPhoneOtp(
        phoneNumber: '+886900000003',
        smsCode: '123456',
      );
      expect(ok, isTrue);

      final audit = await firestore.collection('guestVerifications').get();
      expect(audit.docs.length, 1);
      expect(audit.docs.first.data()['phoneNumber'], '+886900000003');
      expect(audit.docs.first.data()['channel'], 'firebase_phone_otp');
      expect(audit.docs.first.data()['usedForScan'], true);
    });

    test('verifyGuestPhoneOtp returns false when sign in throws', () async {
      final auth = _ThrowingCredentialAuth();
      final service = AuthService(auth: auth, firestore: FakeFirebaseFirestore());
      await service.sendGuestPhoneOtp(
        phoneNumber: '+886900000004',
        onCodeSent: () {},
        onFailed: (_) {},
      );

      final ok = await service.verifyGuestPhoneOtp(
        phoneNumber: '+886900000004',
        smsCode: '000000',
      );
      expect(ok, isFalse);
    });
  });
}

class _ThrowingCredentialAuth extends MockFirebaseAuth {
  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    throw FirebaseAuthException(code: 'invalid-verification-code');
  }
}
