
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../models/customer_review.dart' as review_model;

class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String imageBaseUrl = '$baseUrl/images';

  // Get list of restaurants
  Future<List<Restaurant>> getRestaurantList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> restaurants = data['restaurants'];
        return restaurants.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get restaurant detail
  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/detail/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RestaurantDetail.fromJson(data['restaurant']);
      } else {
        throw Exception('Failed to load restaurant detail');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search restaurants
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> restaurants = data['restaurants'] ?? [];
        return restaurants.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search restaurants');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add review
  Future<List<review_model.CustomerReview>> addReview(
      String id,
      String name,
      String review,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/review'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'name': name,
          'review': review,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> reviews = data['customerReviews'];
        return reviews.map((json) => review_model.CustomerReview.fromJson(json)).toList();
      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get image URL
  static String getImageUrl(String pictureId, {ImageSize size = ImageSize.medium}) {
    String sizeString;
    switch (size) {
      case ImageSize.small:
        sizeString = 'small';
        break;
      case ImageSize.medium:
        sizeString = 'medium';
        break;
      case ImageSize.large:
        sizeString = 'large';
        break;
    }
    return '$imageBaseUrl/$sizeString/$pictureId';
  }
}

enum ImageSize { small, medium, large }