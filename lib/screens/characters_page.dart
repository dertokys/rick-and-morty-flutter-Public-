import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../widgets/character_card.dart';
import '../widgets/fly_to_fav.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key, this.favIconKey});
  final GlobalKey? favIconKey;

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage>
    with AutomaticKeepAliveClientMixin {
  final _controller = ScrollController();
  final List<Character> _items = [];
  final Map<int, GlobalKey> _starKeys = {};
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  GlobalKey _keyFor(int id) => _starKeys.putIfAbsent(id, () => GlobalKey());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    const threshold = 400;
    if (_controller.position.pixels >
        _controller.position.maxScrollExtent - threshold) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _items.clear();
      _currentPage = 0;
      _totalPages = 1;
    });
    final result = await api.fetchCharactersPage(1);
    setState(() {
      _items.addAll(result.items);
      _totalPages = result.totalPages;
      _currentPage = 1;
      _isLoading = false;
    });
  }

  Future<void> _loadNextPage() async {
    if (_isLoading) return;
    if (_currentPage >= _totalPages) return;
    setState(() => _isLoading = true);

    final next = _currentPage + 1;
    final result = await api.fetchCharactersPage(next);

    if (result.emptyCache) {
      setState(() {
        _isLoading = false;
        _totalPages = _currentPage; 
      });
      return;
    }

    setState(() {
      _items.addAll(result.items);
      _currentPage = next;
      _totalPages = result.totalPages;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: ListView.builder(
        key: const PageStorageKey('characters_list'),
        controller: _controller,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  if (_isLoading) const CircularProgressIndicator(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          final ch = _items[index];
          final isFav = favorites.isFavorite(ch.id);
          final starKey = _keyFor(ch.id);

          return Dismissible(
            key: ValueKey('ch_${ch.id}'),
            background: _addBg(context),
            secondaryBackground: _removeBg(context),
            confirmDismiss: (dir) async {
              final rb = starKey.currentContext?.findRenderObject() as RenderBox?;
              final start = rb?.localToGlobal(rb.size.center(Offset.zero));

              if (dir == DismissDirection.startToEnd) {
                if (!isFav) {
                  if (start != null && widget.favIconKey != null) {
                    FlyToFav.runFromPoint(
                      overlayContext: context,
                      start: start,
                      targetKey: widget.favIconKey!,
                      tailCount: kIsWeb ? 5 : 8,
                    );
                  }
                  HapticFeedback.lightImpact();
                  favorites.toggle(ch);
                  setState(() {});
                }
              } else {
                if (isFav) {
                  HapticFeedback.selectionClick();
                  favorites.toggle(ch);
                  setState(() {});
                }
              }
              return false; 
            },
            child: CharacterCard(
              character: ch,
              isFavorite: isFav,
              starKey: starKey,
              onToggleFavorite: (startGlobal) {
                final wasFav = favorites.isFavorite(ch.id);
                if (!wasFav && startGlobal != null && widget.favIconKey != null) {
                  FlyToFav.runFromPoint(
                    overlayContext: context,
                    start: startGlobal,
                    targetKey: widget.favIconKey!,
                    tailCount: kIsWeb ? 5 : 8,
                  );
                }
                favorites.toggle(ch);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  Widget _addBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Colors.green.withValues(alpha: 0.25),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text('В избранное', style: TextStyle(color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _removeBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.errorContainer.withValues(alpha: 0.35),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Убрать из избранного', style: TextStyle(color: cs.onErrorContainer)),
          const SizedBox(width: 8),
          Icon(Icons.star_outline, color: cs.onErrorContainer),
        ],
      ),
    );
  }
}