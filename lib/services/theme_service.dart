import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  SharedPreferences? _prefs;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final s = _prefs!.getString('theme_mode');
    _mode = s == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLight() {
    _mode = ThemeMode.light;
    _prefs?.setString('theme_mode', 'light');
    notifyListeners();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    _prefs?.setString('theme_mode', 'dark');
    notifyListeners();
  }

  void toggle() => isDark ? setLight() : setDark();
}

final themeCtrl = ThemeController();