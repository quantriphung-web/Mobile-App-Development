import 'package:flutter/material.dart';
import 'package:backend/screens/api_service.dart';
import 'package:backend/screens/product_model.dart';

/// Quản lý danh sách yêu thích — đồng bộ với Spring Boot / PostgreSQL.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Set<String> _ids = {};
  bool _loaded = false;

  Set<String> get ids => Set.unmodifiable(_ids);
  bool get isLoaded => _loaded;

  bool isFavorite(String productId) => _ids.contains(productId);

  void applyToProducts<T>(
    List<T> products,
    String Function(T) idOf,
    void Function(T, bool) setFavorite,
  ) {
    for (final p in products) {
      setFavorite(p, isFavorite(idOf(p)));
    }
  }

  Future<void> refresh() async {
    final token = await ApiService.hasAuthToken();
    if (!token) {
      _ids.clear();
      _loaded = true;
      notifyListeners();
      return;
    }

    final ids = await ApiService.getFavoriteProductIds();
    _ids
      ..clear()
      ..addAll(ids);
    _loaded = true;
    notifyListeners();
  }

  Future<List<Product>> loadFavoriteProducts() async {
    final products = await ApiService.getFavoriteProducts();
    for (final p in products) {
      p.isWishlisted = true;
      _ids.add(p.id);
    }
    _loaded = true;
    notifyListeners();
    return products;
  }

  /// Returns `true` if favorited, `false` if removed, `null` if failed / not logged in.
  Future<bool?> toggle(String productId) async {
    final hasToken = await ApiService.hasAuthToken();
    if (!hasToken) return null;

    if (_ids.contains(productId)) {
      final ok = await ApiService.removeFavorite(productId);
      if (ok) {
        _ids.remove(productId);
        notifyListeners();
        return false;
      }
      return null;
    }

    final ok = await ApiService.addFavorite(productId);
    if (ok) {
      _ids.add(productId);
      notifyListeners();
      return true;
    }
    return null;
  }

  Future<bool> remove(String productId) async {
    final ok = await ApiService.removeFavorite(productId);
    if (ok) {
      _ids.remove(productId);
      notifyListeners();
    }
    return ok;
  }
}
