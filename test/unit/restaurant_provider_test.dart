// test/unit/restaurant_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/api_response.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';

void main() {
  group('RestaurantProvider Tests', () {
    late RestaurantProvider provider;

    setUp(() {
      provider = RestaurantProvider();
    });

    test('initial state should be Loading', () {
      expect(provider.restaurantListState, isA<Loading<List<Restaurant>>>());
    });

    test('should initialize with empty search state', () {
      expect(provider.searchState, isA<Success<List<Restaurant>>>());
      expect(provider.lastSearchQuery, isEmpty);
      expect(provider.hasSearched, isFalse);
    });

    test('should handle clear search correctly', () {
      // Act
      provider.clearSearch();

      // Assert
      expect(provider.searchState, isA<Success<List<Restaurant>>>());
      expect(provider.lastSearchQuery, isEmpty);
      expect(provider.hasSearched, isFalse);
    });

    test('should track adding review state', () {
      expect(provider.isAddingReview, isFalse);
    });

    test('should handle empty search query', () async {
      // Act
      await provider.searchRestaurants('');

      // Assert
      expect(provider.hasSearched, isFalse);
      if (provider.searchState is Success<List<Restaurant>>) {
        final state = provider.searchState as Success<List<Restaurant>>;
        expect(state.data, isEmpty);
      }
    });
  });
}



