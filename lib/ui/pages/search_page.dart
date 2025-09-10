// lib/ui/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../data/models/api_response.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    _searchController.text = provider.lastSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Provider.of<RestaurantProvider>(context, listen: false)
          .searchRestaurants(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Restaurants'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants, food, or drinks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<RestaurantProvider>(context, listen: false)
                        .clearSearch();
                  },
                )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  Provider.of<RestaurantProvider>(context, listen: false)
                      .clearSearch();
                }
              },
            ),
          ),

          // Search Button
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _performSearch(_searchController.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Search Results
          Expanded(
            child: Consumer<RestaurantProvider>(
              builder: (context, provider, child) {
                return switch (provider.searchState) {
                  Loading() => const LoadingWidget(message: 'Searching restaurants...'),
                  Success(data: final restaurants) => restaurants.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(
                        restaurant: restaurants[index],
                        heroTag: 'search_restaurant_${restaurants[index].id}',
                      );
                    },
                  ),
                  Error(message: final message) => CustomErrorWidget(
                    message: message,
                    onRetry: () => _performSearch(_searchController.text),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'No restaurants found'
                  : 'Start searching',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try searching with different keywords'
                  : 'Search for restaurants, food, or drinks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}