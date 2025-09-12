
// test/unit/api_response_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/models/api_response.dart';
import 'package:restaurant_app/data/models/restaurant.dart';

void main() {
  group('ApiResponse Tests', () {
    test('Loading state should be created correctly', () {
      final loading = Loading<List<Restaurant>>();
      expect(loading, isA<Loading<List<Restaurant>>>());
      expect(loading, isA<ApiResponse<List<Restaurant>>>());
    });

    test('Success state should hold data correctly', () {
      final testData = [
        Restaurant(
          id: '1',
          name: 'Test',
          description: 'Desc',
          pictureId: 'pic1',
          city: 'City',
          rating: 4.5,
        )
      ];
      final success = Success<List<Restaurant>>(testData);

      expect(success, isA<Success<List<Restaurant>>>());
      expect(success, isA<ApiResponse<List<Restaurant>>>());
      expect(success.data, equals(testData));
      expect(success.data.length, equals(1));
      expect(success.data[0].name, equals('Test'));
    });

    test('Error state should hold message correctly', () {
      const errorMessage = 'Test error message';
      final error = Error<List<Restaurant>>(errorMessage);

      expect(error, isA<Error<List<Restaurant>>>());
      expect(error, isA<ApiResponse<List<Restaurant>>>());
      expect(error.message, equals(errorMessage));
    });
  });
}