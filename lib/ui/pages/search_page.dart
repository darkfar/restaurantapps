import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/api_response.dart';
import '../../data/models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/restaurant_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Restoran'),
      ),
      body: Column(
        children: [
          // Search Bar
          Consumer<RestaurantProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari restoran favorit Anda...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.lastSearchQuery.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        provider.clearSearch();
                      },
                      icon: const Icon(Icons.clear),
                    )
                        : null,
                  ),
                  onChanged: provider.searchRestaurants,
                  onSubmitted: provider.searchRestaurants,
                ),
              );
            },
          ),
          // Search Results
          Expanded(
            child: Consumer<RestaurantProvider>(
              builder: (context, provider, child) {
                // Show initial search prompt
                if (!provider.hasSearched) {
                  return _buildSearchPrompt(context, provider);
                }

                // Show search results
                return _buildSearchResults(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPrompt(BuildContext context, RestaurantProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Cari Restoran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Masukkan nama restoran yang ingin Anda cari',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Focus will be handled automatically when user taps the search field
            },
            icon: const Icon(Icons.search),
            label: const Text('Mulai Pencarian'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(RestaurantProvider provider) {
    switch (provider.searchState) {
      case Loading<List<Restaurant>>():
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mencari restoran...'),
            ],
          ),
        );

      case Success<List<Restaurant>>(data: final restaurants):
        if (restaurants.isEmpty && provider.lastSearchQuery.isNotEmpty) {
          return _buildNoResults(provider);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(restaurant: restaurants[index]);
          },
        );

      case Error<List<Restaurant>>(message: final message):
        return CustomErrorWidget(
          error: message,
          title: 'Pencarian Gagal',
          onRetry: () => provider.searchRestaurants(provider.lastSearchQuery),
        );
    }
  }

  Widget _buildNoResults(RestaurantProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak Ditemukan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada restoran yang cocok dengan pencarian "${provider.lastSearchQuery}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              provider.clearSearch();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Cari Lagi'),
          ),
        ],
      ),
    );
  }
}