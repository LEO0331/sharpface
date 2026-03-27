import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharpface/core/cache/local_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalCacheService cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = LocalCacheService();
  });

  test('saveIfChanged only writes when value changes', () async {
    final changed1 = await cache.saveIfChanged('k1', {'a': 1});
    final changed2 = await cache.saveIfChanged('k1', {'a': 1});
    final changed3 = await cache.saveIfChanged('k1', {'a': 2});

    expect(changed1, isTrue);
    expect(changed2, isFalse);
    expect(changed3, isTrue);
  });

  test('readFreshJsonMap returns null when ttl expired metadata missing', () async {
    await cache.saveJson('k2', {'a': 1});
    final data = await cache.readFreshJsonMap('k2');
    expect(data, isNull);
  });

  test('readFreshJsonMap returns data within ttl window', () async {
    await cache.saveJsonWithTtl(
      key: 'k3',
      value: {'a': 1},
      ttl: const Duration(minutes: 10),
    );
    final data = await cache.readFreshJsonMap('k3');
    expect(data, isNotNull);
    expect(data?['a'], 1);
  });
}
