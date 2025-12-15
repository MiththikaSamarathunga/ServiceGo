import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  Future<List<String>> getFavorites(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('${_favoritesKey}_$userId');
      if (favoritesJson != null) {
        return List<String>.from(json.decode(favoritesJson));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(String userId, String providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = await getFavorites(userId);
      if (!favorites.contains(providerId)) {
        favorites.add(providerId);
        await prefs.setString('${_favoritesKey}_$userId', json.encode(favorites));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favorites = await getFavorites(userId);
      favorites.remove(providerId);
      await prefs.setString('${_favoritesKey}_$userId', json.encode(favorites));
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFavorite(String userId, String providerId) async {
    final favorites = await getFavorites(userId);
    return favorites.contains(providerId);
  }
}
