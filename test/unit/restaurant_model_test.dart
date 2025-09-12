
// test/unit/restaurant_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/restaurant.dart';

void main() {
  group('Restaurant Model Tests', () {
    test('should create restaurant from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Test Restaurant',
        'description': 'Test description',
        'pictureId': 'pic1',
        'city': 'Test City',
        'rating': 4.5,
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, equals('1'));
      expect(restaurant.name, equals('Test Restaurant'));
      expect(restaurant.description, equals('Test description'));
      expect(restaurant.pictureId, equals('pic1'));
      expect(restaurant.city, equals('Test City'));
      expect(restaurant.rating, equals(4.5));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, equals(''));
      expect(restaurant.name, equals(''));
      expect(restaurant.description, equals(''));
      expect(restaurant.pictureId, equals(''));
      expect(restaurant.city, equals(''));
      expect(restaurant.rating, equals(0.0));
    });

    test('should convert to JSON correctly', () {
      final restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test description',
        pictureId: 'pic1',
        city: 'Test City',
        rating: 4.5,
      );

      final json = restaurant.toJson();

      expect(json['id'], equals('1'));
      expect(json['name'], equals('Test Restaurant'));
      expect(json['description'], equals('Test description'));
      expect(json['pictureId'], equals('pic1'));
      expect(json['city'], equals('Test City'));
      expect(json['rating'], equals(4.5));
    });

    test('should handle rating as int from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'description': 'Desc',
        'pictureId': 'pic1',
        'city': 'City',
        'rating': 4, // Integer instead of double
      };

      final restaurant = Restaurant.fromJson(json);
      expect(restaurant.rating, equals(4.0));
      expect(restaurant.rating, isA<double>());
    });
  });
}