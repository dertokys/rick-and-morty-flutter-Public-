import 'package:flutter/material.dart';
import 'screens/characters_page.dart';
import 'screens/favorites_page.dart';
import 'services/theme_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 0;

  final GlobalKey _favIconKey = GlobalKey();

  final PageStorageBucket _bucket = PageStorageBucket();

  late final ThemeData _light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
    useMaterial3: true,
  );
  late final ThemeData _dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
    useMaterial3: true,
  );

  late final Widget _charactersPage;
  late final Widget _favoritesPage;

  @override
  void initState() {
    super.initState();
    _charactersPage = CharactersPage(
      key: const PageStorageKey('page_characters'),
      favIconKey: _favIconKey, 
    );
    _favoritesPage = const FavoritesPage(
      key: PageStorageKey('page_favorites'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeCtrl,
      builder: (context, _) {
        final cs = (themeCtrl.isDark ? _dark : _light).colorScheme;
        final active = cs.primary;
        final inactive = cs.onSurfaceVariant;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rick & Morty',
          themeMode: themeCtrl.mode,
          theme: _light,
          darkTheme: _dark,
          themeAnimationDuration: const Duration(milliseconds: 220),
          themeAnimationCurve: Curves.easeOutCubic,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Rick & Morty'),
              actions: [
                IconButton(
                  tooltip: 'Светлая тема',
                  onPressed: themeCtrl.setLight,
                  icon: Icon(Icons.light_mode, color: themeCtrl.isDark ? inactive : active),
                ),
                IconButton(
                  tooltip: 'Тёмная тема',
                  onPressed: themeCtrl.setDark,
                  icon: Icon(Icons.dark_mode, color: themeCtrl.isDark ? active : inactive),
                ),
              ],
            ),
            body: PageStorage(
              bucket: _bucket,
              child: IndexedStack(
                index: _index,
                children: [
                  _charactersPage,
                  _favoritesPage,
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.list),
                  label: 'Персонажи',
                ),
                NavigationDestination(
                  icon: RepaintBoundary(
                    key: _favIconKey,
                    child: const Icon(Icons.star_border),
                  ),
                  selectedIcon: const Icon(Icons.star),
                  label: 'Избранное',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}