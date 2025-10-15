import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

enum FavSort { nameAsc, nameDesc, status }

class FavoritesService extends ChangeNotifier {
  SharedPreferences? _prefs;
  final Set<int> _ids = <int>{};
  final Map<int, Character> _map = <int, Character>{};
  FavSort _sort = FavSort.nameAsc;

  FavSort get sort => _sort;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // ids
    final ids = _prefs!.getStringList('favorites_ids') ?? const <String>[];
    for (final s in ids) {
      final id = int.tryParse(s);
      if (id != null) _ids.add(id);
    }
    // payloads
    for (final id in _ids) {
      final raw = _prefs!.getString('fav_$id');
      if (raw != null) {
        try {
          _map[id] = Character.fromJson(json.decode(raw) as Map<String, dynamic>);
        } catch (_) {}
      }
    }
    // sort
    final sortStr = _prefs!.getString('favorites_sort');
    _sort = switch (sortStr) {
      'name_desc' => FavSort.nameDesc,
      'status' => FavSort.status,
      _ => FavSort.nameAsc,
    };
    notifyListeners();
  }

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> toggle(Character c) async {
    if (_prefs == null) return;
    if (_ids.contains(c.id)) {
      _ids.remove(c.id);
      _map.remove(c.id);
      await _prefs!.remove('fav_${c.id}');
    } else {
      _ids.add(c.id);
      _map[c.id] = c;
      await _prefs!.setString('fav_${c.id}', json.encode(c.toJson()));
    }
    await _prefs!.setStringList('favorites_ids', _ids.map((e) => e.toString()).toList());
    notifyListeners();
  }

  void setSort(FavSort sort) {
    _sort = sort;
    _prefs?.setString('favorites_sort', switch (sort) {
      FavSort.nameAsc => 'name_asc',
      FavSort.nameDesc => 'name_desc',
      FavSort.status => 'status',
    });
    notifyListeners();
  }

  List<Character> sorted() {
    final items = _ids.map((id) => _map[id]).whereType<Character>().toList();
    switch (_sort) {
      case FavSort.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case FavSort.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case FavSort.status:
        int order(String s) {
          switch (s.toLowerCase()) {
            case 'alive':
              return 0;
            case 'dead':
              return 1;
            default:
              return 2;
          }
        }
        items.sort((a, b) {
          final byStatus = order(a.status).compareTo(order(b.status));
          return byStatus != 0 ? byStatus : a.name.compareTo(b.name);
        });
        break;
    }
    return items;
  }
}

final favorites = FavoritesService();