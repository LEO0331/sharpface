import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('registerWithEmailPassword creates users doc with role user', () async {
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
    });

    test('isAdmin returns true when user role is admin', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('admin-1').set({
        'email': 'admin@example.com',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final service = AuthService(auth: MockFirebaseAuth(), firestore: firestore);
      final result = await service.isAdmin('admin-1');
      expect(result, true);
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

      final service = AuthService(auth: auth, firestore: FakeFirebaseFirestore());
      final credential = await service.signInWithEmailPassword(
        email: 'a@example.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'a@example.com');
      expect(auth.currentUser, isNotNull);
    });
  });
}
