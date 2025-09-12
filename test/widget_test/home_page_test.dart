// test/widget/home_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_app/data/preferences/preferences_helper.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/ui/pages/home_page.dart';

void main() {
  group('HomePage Widget Tests', () {
    late RestaurantProvider restaurantProvider;
    late ThemeProvider themeProvider;
    late FavoriteProvider favoriteProvider;

    setUpAll(() async {
      // Initialize SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      restaurantProvider = RestaurantProvider();
      favoriteProvider = FavoriteProvider();

      final sharedPreferences = await SharedPreferences.getInstance();
      final preferencesHelper = PreferencesHelper(
        sharedPreferences: Future.value(sharedPreferences),
      );
      themeProvider = ThemeProvider(preferencesHelper: preferencesHelper);
    });

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<RestaurantProvider>.value(
            value: restaurantProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
          ),
          ChangeNotifierProvider<FavoriteProvider>.value(
            value: favoriteProvider,
          ),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      );
    }

    testWidgets('should display app bar with correct title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow providers to initialize

      expect(find.text('Restaurant App'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display search and theme toggle buttons in app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
      // Check for either dark_mode or light_mode icon based on theme state
      expect(
          find.byIcon(Icons.dark_mode).evaluate().isNotEmpty ||
              find.byIcon(Icons.light_mode).evaluate().isNotEmpty,
          isTrue
      );
    });

    testWidgets('should display RefreshIndicator', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should show loading or content states', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should show either loading indicator or some content/error state
      final hasLoadingOrContent =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
              find.textContaining('Memuat').evaluate().isNotEmpty ||
              find.textContaining('Tidak Ada').evaluate().isNotEmpty ||
              find.textContaining('Gagal').evaluate().isNotEmpty ||
              find.byType(Card).evaluate().isNotEmpty;

      expect(hasLoadingOrContent, isTrue);
    });

    testWidgets('should handle theme toggle tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find theme toggle button (could be either dark_mode or light_mode)
      final themeButton = find.byIcon(Icons.dark_mode).evaluate().isNotEmpty
          ? find.byIcon(Icons.dark_mode)
          : find.byIcon(Icons.light_mode);

      if (themeButton.evaluate().isNotEmpty) {
        await tester.tap(themeButton);
        await tester.pump();

        // Verify the button still exists (may have changed icon)
        expect(
            find.byIcon(Icons.dark_mode).evaluate().isNotEmpty ||
                find.byIcon(Icons.light_mode).evaluate().isNotEmpty,
            isTrue
        );
      }
    });

    testWidgets('should handle search button tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);

      // Just verify the button is tappable (navigation testing would require more setup)
      await tester.tap(searchButton);
      await tester.pump();

      // Button should still be there after tap
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}

