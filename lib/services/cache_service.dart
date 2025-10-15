import 'cache_service_io.dart' if (dart.library.html) 'cache_service_web.dart' as impl;

class CacheService {
  static Future<void> savePage(int page, String body) => impl.savePage(page, body);
  static Future<Map<String, dynamic>?> readPage(int page) => impl.readPage(page);
}