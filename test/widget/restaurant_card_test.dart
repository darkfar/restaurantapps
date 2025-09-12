// test/widget/restaurant_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/data/preferences/preferences_helper.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/ui/widgets/restaurant_card.dart';

void main() {
  group('RestaurantCard Widget Tests', () {
    late FavoriteProvider favoriteProvider;
    late ThemeProvider themeProvider;
    late Restaurant testRestaurant;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      favoriteProvider = FavoriteProvider();

      final sharedPreferences = await SharedPreferences.getInstance();
      final preferencesHelper = PreferencesHelper(
        sharedPreferences: Future.value(sharedPreferences),
      );
      themeProvider = ThemeProvider(preferencesHelper: preferencesHelper);

      testRestaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'This is a test restaurant with a great menu and atmosphere.',
        pictureId: 'test-pic',
        city: 'Test City',
        rating: 4.5,
      );
    });

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoriteProvider>.value(
            value: favoriteProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: RestaurantCard(restaurant: testRestaurant),
          ),
        ),
      );
    }

    testWidgets('should display restaurant information correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should display favorite button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should show either favorite or favorite_border icon
      expect(
          find.byIcon(Icons.favorite).evaluate().isNotEmpty ||
              find.byIcon(Icons.favorite_border).evaluate().isNotEmpty,
          isTrue
      );
    });

    testWidgets('should handle favorite button tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final favoriteButton = find.byIcon(Icons.favorite_border).evaluate().isNotEmpty
          ? find.byIcon(Icons.favorite_border)
          : find.byIcon(Icons.favorite);

      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pump();

        // Button should still exist after tap
        expect(
            find.byIcon(Icons.favorite).evaluate().isNotEmpty ||
                find.byIcon(Icons.favorite_border).evaluate().isNotEmpty,
            isTrue
        );
      }
    });

    testWidgets('should display card container', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should handle card tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final cardWidget = find.byType(InkWell);
      expect(cardWidget, findsOneWidget);

      await tester.tap(cardWidget);
      await tester.pump();

      // Card should still be there after tap
      expect(find.byType(Card), findsOneWidget);
    });
  });
}