import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite.dart';

Future<void> saveFavorites(List<Favorite> favs) async {
  final pref = await SharedPreferences.getInstance();
  // Favorite のリストを Map のリストに変換
  List<Map<String, dynamic>> favoriteMaps = favs.map((f) => f.toMap()).toList();
  // JSON にエンコードして保存
  String jsonString = jsonEncode(favoriteMaps);
  await pref.setString("favs", jsonString);
}

Future<List<Favorite>> loadFavorites(SharedPreferences? pref) async {
  if (pref == null) return [];
  // JSON 文字列を取得
  String? jsonString = pref.getString('favs');
  if (jsonString == null) return [];

  // JSON 文字列をデコードし、Favorite のリストに変換
  List<dynamic> decodedList = jsonDecode(jsonString);
  List<Favorite> favorites =
      decodedList.map((map) => Favorite.fromMap(map)).toList();

  return favorites;
}
