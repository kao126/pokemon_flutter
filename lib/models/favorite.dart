import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/favorite.dart';

class FavoritesNotifier extends ChangeNotifier {
  late List<Favorite> _favs = [];

  FavoritesNotifier(SharedPreferences pref) {
    _init(pref);
  }

  List<Favorite> get favs => _favs;

  void _init(SharedPreferences pref) async {
    _favs = await loadFavorites(pref);
    notifyListeners();
  }

  void toggle(Favorite fav) {
    if (isExist(fav.pokeId)) {
      delete(fav.pokeId);
    } else {
      add(fav);
    }
  }

  bool isExist(int id) {
    if (_favs.indexWhere((fav) => fav.pokeId == id) < 0) {
      return false;
    }
    return true;
  }

  void add(Favorite fav) {
    favs.add(fav);
    saveFavorites(favs);
    notifyListeners();
  }

  void delete(int id) {
    favs.removeWhere((fav) => fav.pokeId == id);
    saveFavorites(favs);
    notifyListeners();
  }
}

class Favorite {
  final int pokeId;

  Favorite({
    required this.pokeId,
  });

  // Map に変換（保存用）
  Map<String, dynamic> toMap() {
    return {
      'id': pokeId,
    };
  }

  // Map から Favorite インスタンスを作成（復元用）
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(pokeId: map['id']);
  }
}
