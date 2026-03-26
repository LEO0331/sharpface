import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/services/ads_service.dart';
import 'package:sharpface/services/auth_service.dart';
import 'package:sharpface/services/favorite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Auth + Favorites + Ads config integration flow', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();

    final authService = AuthService(auth: auth, firestore: firestore);
    final favService = FavoriteService(firestore: firestore);
    final adsService = AdsService(firestore: firestore);

    final credential = await authService.registerWithEmailPassword(
      email: 'flow@example.com',
      password: '123456',
    );
    expect(credential.user, isNotNull);

    final uid = credential.user!.uid;
    final userDoc = await firestore.collection('users').doc(uid).get();
    expect(userDoc.data()?['role'], 'user');

    const product = Product(
      id: 'p1',
      name: 'Test Product',
      price: 88,
      mainIngredients: ['A', 'B'],
      rating: 2,
      affiliateUrl: 'https://example.com',
      isFeatured: false,
      clickCount: 0,
    );
    await favService.addFavorite(uid: uid, product: product);

    final favorites = await favService.watchFavorites(uid).first;
    expect(favorites.length, 1);
    expect(favorites.first.name, 'Test Product');

    await adsService.savePoolConfig(
      const AdPoolConfig(
        pool: 'acne',
        messages: ['acne ad 1'],
        enabled: true,
        priority: 200,
      ),
    );
    await adsService.savePoolConfig(
      const AdPoolConfig(
        pool: 'general',
        messages: ['general ad 1'],
        enabled: true,
        priority: 50,
      ),
    );

    final acne = await adsService.getPoolConfigOnce('acne');
    final general = await adsService.getPoolConfigOnce('general');
    expect(acne.priority > general.priority, true);
    expect(acne.enabled, true);
    expect(acne.messages.first, 'acne ad 1');
  });
}
