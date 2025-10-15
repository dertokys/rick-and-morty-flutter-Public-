import 'package:flutter/material.dart';
import 'app.dart';
import 'services/favorites_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    favorites.init(),
    themeCtrl.init(),
  ]);
  runApp(const MyApp());
}