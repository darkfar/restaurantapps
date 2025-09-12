// lib/providers/favorite_provider.dart
import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../data/models/restaurant.dart';

class FavoriteProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Restaurant> _favorites = [];
  List<Restaurant> get favorites => _favorites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, bool> _favoriteStatus = {};

  // Constructor
  FavoriteProvider() {
    _loadFavorites();
  }

  // Load favorites from database
  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _databaseHelper.getFavorites();
      _updateFavoriteStatus();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update favorite status map for quick lookup
  void _updateFavoriteStatus() {
    _favoriteStatus.clear();
    for (final restaurant in _favorites) {
      _favoriteStatus[restaurant.id] = true;
    }
  }

  // Check if restaurant is favorite
  bool isFavorite(String id) {
    return _favoriteStatus[id] ?? false;
  }

  // Add restaurant to favorites
  Future<void> addToFavorite(Restaurant restaurant) async {
    try {
      await _databaseHelper.insertFavorite(restaurant);
      _favorites.add(restaurant);
      _favoriteStatus[restaurant.id] = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove restaurant from favorites
  Future<void> removeFromFavorite(String id) async {
    try {
      await _databaseHelper.removeFavorite(id);
      _favorites.removeWhere((restaurant) => restaurant.id == id);
      _favoriteStatus.remove(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Restaurant restaurant) async {
    if (isFavorite(restaurant.id)) {
      await removeFromFavorite(restaurant.id);
    } else {
      await addToFavorite(restaurant);
    }
  }

  // Refresh favorites list
  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _databaseHelper.clearFavorites();
      _favorites.clear();
      _favoriteStatus.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all favorites: $e');
      rethrow;
    }
  }

  // Get favorite count
  int get favoriteCount => _favorites.length;

  // Check if favorites list is empty
  bool get isEmpty => _favorites.isEmpty;
  bool get isNotEmpty => _favorites.isNotEmpty;
}