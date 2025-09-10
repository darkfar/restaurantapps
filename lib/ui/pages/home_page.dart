// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../main.dart'; // Import for ThemeProvider
import '../../data/models/api_response.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchRestaurantList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          return switch (provider.restaurantListState) {
            Loading() => const LoadingWidget(),
            Success(data: final restaurants) => RefreshIndicator(
              onRefresh: () => provider.fetchRestaurantList(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return RestaurantCard(
                    restaurant: restaurants[index],
                    heroTag: 'restaurant_${restaurants[index].id}',
                  );
                },
              ),
            ),
            Error(message: final message) => CustomErrorWidget(
              message: message,
              onRetry: () => provider.fetchRestaurantList(),
            ),
          };
        },
      ),
    );
  }
}