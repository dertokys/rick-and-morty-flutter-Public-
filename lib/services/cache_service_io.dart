import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> _pageFile(int page) async {
  final dir = await getApplicationDocumentsDirectory();
  final cacheDir = Directory('${dir.path}/rnm_cache');
  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }
  return File('${cacheDir.path}/characters_page_$page.json');
}

Future<void> savePage(int page, String body) async {
  final f = await _pageFile(page);
  await f.writeAsString(body, flush: true);
}

Future<Map<String, dynamic>?> readPage(int page) async {
  try {
    final f = await _pageFile(page);
    if (await f.exists()) {
      final s = await f.readAsString();
      return json.decode(s) as Map<String, dynamic>;
    }
  } catch (_) {}
  return null;
}