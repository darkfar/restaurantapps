
import 'package:flutter/material.dart';
import '../data/models/api_response.dart';
import '../data/models/restaurant.dart';
import '../data/models/restaurant_detail.dart';
import '../data/services/api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ApiResponse<List<Restaurant>> _restaurantListState = Loading<List<Restaurant>>();
  ApiResponse<List<Restaurant>> get restaurantListState => _restaurantListState;

  ApiResponse<RestaurantDetail> _restaurantDetailState = Loading<RestaurantDetail>();
  ApiResponse<RestaurantDetail> get restaurantDetailState => _restaurantDetailState;

  ApiResponse<List<Restaurant>> _searchState = Success<List<Restaurant>>([]);
  ApiResponse<List<Restaurant>> get searchState => _searchState;

  bool _isAddingReview = false;
  bool get isAddingReview => _isAddingReview;

  String _lastSearchQuery = '';
  String get lastSearchQuery => _lastSearchQuery;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  // Get restaurant list
  Future<void> fetchRestaurantList() async {
    _restaurantListState = Loading<List<Restaurant>>();
    notifyListeners();

    try {
      final restaurants = await _apiService.getRestaurantList();
      _restaurantListState = Success<List<Restaurant>>(restaurants);
    } catch (e) {
      _restaurantListState = Error<List<Restaurant>>(_getErrorMessage(e));
    }
    notifyListeners();
  }

  // Get restaurant detail
  Future<void> fetchRestaurantDetail(String id) async {
    _restaurantDetailState = Loading<RestaurantDetail>();
    notifyListeners();

    try {
      final restaurant = await _apiService.getRestaurantDetail(id);
      _restaurantDetailState = Success<RestaurantDetail>(restaurant);
    } catch (e) {
      _restaurantDetailState = Error<RestaurantDetail>(_getErrorMessage(e));
    }
    notifyListeners();
  }

  // Search restaurants
  Future<void> searchRestaurants(String query) async {
    _lastSearchQuery = query;
    _hasSearched = true;

    if (query.isEmpty) {
      _searchState = Success<List<Restaurant>>([]);
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _searchState = Loading<List<Restaurant>>();
    notifyListeners();

    try {
      final restaurants = await _apiService.searchRestaurants(query);
      _searchState = Success<List<Restaurant>>(restaurants);
    } catch (e) {
      _searchState = Error<List<Restaurant>>(_getErrorMessage(e));
    }
    notifyListeners();
  }

  // Add review
  Future<bool> addReview(String restaurantId, String name, String review) async {
    _isAddingReview = true;
    notifyListeners();

    try {
      final updatedReviews = await _apiService.addReview(restaurantId, name, review);

      // Update the current restaurant detail if it's loaded and matches the ID
      if (_restaurantDetailState is Success<RestaurantDetail>) {
        final currentDetail = (_restaurantDetailState as Success<RestaurantDetail>).data;
        if (currentDetail.id == restaurantId) {
          // Convert review_model.CustomerReview to RestaurantDetail.CustomerReview
          final convertedReviews = updatedReviews.map((review) => CustomerReview(
            name: review.name,
            review: review.review,
            date: review.date,
          )).toList();

          final updatedDetail = RestaurantDetail(
            id: currentDetail.id,
            name: currentDetail.name,
            description: currentDetail.description,
            city: currentDetail.city,
            address: currentDetail.address,
            pictureId: currentDetail.pictureId,
            categories: currentDetail.categories,
            menus: currentDetail.menus,
            rating: currentDetail.rating,
            customerReviews: convertedReviews,
          );
          _restaurantDetailState = Success<RestaurantDetail>(updatedDetail);
        }
      }

      _isAddingReview = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAddingReview = false;
      notifyListeners();
      return false;
    }
  }

  // Reset search
  void clearSearch() {
    _searchState = Success<List<Restaurant>>([]);
    _lastSearchQuery = '';
    _hasSearched = false;
    notifyListeners();
  }

  // Helper method untuk error message yang user-friendly
  String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (errorString.contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi.';
    } else if (errorString.contains('404')) {
      return 'Data tidak ditemukan.';
    } else if (errorString.contains('500')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    } else if (errorString.contains('failed to load')) {
      return 'Gagal memuat data. Silakan coba lagi.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}