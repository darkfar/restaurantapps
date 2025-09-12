// test/widget_test.dart (Corrected)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/utils/notification_helper.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize mock shared preferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final notificationHelper = NotificationHelper();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      sharedPreferences: sharedPreferences,
      notificationHelper: notificationHelper,
    ));

    // Verify that the app starts successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}