import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import 'cache_service.dart';

class PageResult {
  final List<Character> items;
  final int totalPages;
  final bool fromCache;
  final bool emptyCache; 
  const PageResult({
    required this.items,
    required this.totalPages,
    required this.fromCache,
    this.emptyCache = false,
  });
}

class ApiService {
  static const _base = 'https://rickandmortyapi.com/api';

  Future<PageResult> fetchCharactersPage(int page) async {
    final url = Uri.parse('$_base/character?page=$page');
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      await CacheService.savePage(page, res.body);
      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = (data['results'] as List)
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalPages = (data['info']?['pages'] as int?) ?? 1;
      return PageResult(items: items, totalPages: totalPages, fromCache: false);
    } catch (_) {
      final cached = await CacheService.readPage(page);
      if (cached != null) {
        final items = (cached['results'] as List)
            .map((e) => Character.fromJson(e as Map<String, dynamic>))
            .toList();
        final totalPages = (cached['info']?['pages'] as int?) ?? 1;
        return PageResult(
          items: items,
          totalPages: totalPages,
          fromCache: true,
          emptyCache: false,
        );
      }
      return const PageResult(
        items: [],
        totalPages: 1,
        fromCache: true,
        emptyCache: true,
      );
    }
  }
}

final api = ApiService();