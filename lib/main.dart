// lib/main.dart (Updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/preferences/preferences_helper.dart';
import 'providers/restaurant_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/pages/main_navigation.dart';
import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize NotificationHelper
  final notificationHelper = NotificationHelper();
  await notificationHelper.initNotifications();

  runApp(MyApp(
    sharedPreferences: sharedPreferences,
    notificationHelper: notificationHelper,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final NotificationHelper notificationHelper;

  const MyApp({
    super.key,
    required this.sharedPreferences,
    required this.notificationHelper,
  });

  @override
  Widget build(BuildContext context) {
    final preferencesHelper = PreferencesHelper(
      sharedPreferences: Future.value(sharedPreferences),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(
            preferencesHelper: preferencesHelper,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(
            preferencesHelper: preferencesHelper,
            notificationHelper: notificationHelper,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Show loading screen while theme is being loaded
          if (themeProvider.isLoading) {
            return MaterialApp(
              title: 'Restaurant App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp(
            title: 'Restaurant App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}