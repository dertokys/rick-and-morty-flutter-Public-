import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> savePage(int page, String body) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('cache_page_$page', body);
}

Future<Map<String, dynamic>?> readPage(int page) async {
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString('cache_page_$page');
  if (s == null) return null;
  try {
    return json.decode(s) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}