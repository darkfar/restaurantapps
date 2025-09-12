// test/unit/favorite_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';

void main() {
  group('FavoriteProvider Tests', () {
    late FavoriteProvider provider;

    setUp(() {
      provider = FavoriteProvider();
    });

    final testRestaurant = Restaurant(
      id: '1',
      name: 'Test Restaurant',
      description: 'Test description',
      pictureId: 'pic1',
      city: 'Test City',
      rating: 4.5,
    );

    test('initial state should be empty favorites list', () {
      expect(provider.favorites, isEmpty);
      expect(provider.favoriteCount, equals(0));
      expect(provider.isEmpty, isTrue);
      expect(provider.isNotEmpty, isFalse);
    });

    test('should check if restaurant is not favorite initially', () {
      expect(provider.isFavorite(testRestaurant.id), isFalse);
      expect(provider.isFavorite('non_existent_id'), isFalse);
    });

    test('should handle loading state correctly', () {
      expect(provider.isLoading, isA<bool>());
    });

    test('should return correct favorite count initially', () {
      expect(provider.favoriteCount, equals(0));
    });
  });
}