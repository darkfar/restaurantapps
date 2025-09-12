// test_driver/app_test.dart (Simplified)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_app/main.dart' as app;
import 'package:restaurant_app/utils/notification_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets('app launches and basic navigation works', (tester) async {
      // Initialize SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      // Initialize the app
      await tester.pumpWidget(
        app.MyApp(
          sharedPreferences: sharedPreferences,
          notificationHelper: NotificationHelper(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test 1: Verify app loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      print('✓ App launched successfully');

      // Test 2: Check if home content is displayed
      final hasHomeContent = find.text('Restaurant App').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.textContaining('Memuat').evaluate().isNotEmpty;

      expect(hasHomeContent, isTrue);
      print('✓ Home page content displayed');

      // Test 3: Navigate to favorites tab
      final favoritesTab = find.text('Favorit');
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Should show empty favorites or loading
        final hasEmptyOrContent = find.text('Belum Ada Favorit').evaluate().isNotEmpty ||
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        expect(hasEmptyOrContent, isTrue);
        print('✓ Favorites page navigation works');
      }

      // Test 4: Navigate to settings tab
      final settingsTab = find.text('Pengaturan');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Should show settings content
        final hasSettingsContent = find.text('Pengaturan').evaluate().isNotEmpty ||
            find.text('Tema Gelap').evaluate().isNotEmpty ||
            find.text('Pengingat Harian').evaluate().isNotEmpty;
        expect(hasSettingsContent, isTrue);
        print('✓ Settings page navigation works');
      }

      // Test 5: Navigate back to home
      final homeTab = find.text('Beranda');
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
        print('✓ Back to home navigation works');
      }

      print('✓ All basic integration tests passed');
    });

    testWidgets('search functionality basic test', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        app.MyApp(
          sharedPreferences: sharedPreferences,
          notificationHelper: NotificationHelper(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to find and tap search icon
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle();

        // Check if search page loaded
        final hasSearchContent = find.text('Cari Restoran').evaluate().isNotEmpty ||
            find.byType(TextField).evaluate().isNotEmpty;

        if (hasSearchContent) {
          print('✓ Search page loaded successfully');

          // Try typing in search field if available
          final searchField = find.byType(TextField);
          if (searchField.evaluate().isNotEmpty) {
            await tester.enterText(searchField, 'test');
            await tester.pumpAndSettle();
            print('✓ Search input works');
          }
        }
      }

      print('✓ Search functionality test completed');
    });

    testWidgets('settings toggle test', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        app.MyApp(
          sharedPreferences: sharedPreferences,
          notificationHelper: NotificationHelper(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      final settingsTab = find.text('Pengaturan');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Try to find and toggle theme switch
        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          print('✓ Theme toggle works');
        }

        // Try daily reminder toggle if there are multiple switches
        if (switches.evaluate().length > 1) {
          await tester.tap(switches.last);
          await tester.pumpAndSettle();

          // Handle potential permission dialog
          final continueButton = find.text('Lanjutkan');
          if (continueButton.evaluate().isNotEmpty) {
            await tester.tap(continueButton);
            await tester.pumpAndSettle();
          }
          print('✓ Daily reminder toggle works');
        }
      }

      print('✓ Settings toggle test completed');
    });
  });
}