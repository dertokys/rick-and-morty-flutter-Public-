import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/favorites_service.dart';
import '../widgets/character_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin {
  final _listKey = GlobalKey<AnimatedListState>();
  List<Character> _items = [];

  final Map<int, DismissDirection> _lastDismissDir = <int, DismissDirection>{};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _items = favorites.sorted();
    favorites.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    final target = favorites.sorted();
    final targetIds = target.map((e) => e.id).toSet();
    final currentIds = _items.map((e) => e.id).toSet();

    for (int i = _items.length - 1; i >= 0; i--) {
      final ch = _items[i];
      if (!targetIds.contains(ch.id)) {
        _removeAt(i, animate: true, toggleAlreadyDone: true);
      }
    }

    for (int i = 0; i < target.length; i++) {
      final ch = target[i];
      if (!currentIds.contains(ch.id)) {
        _items.insert(i, ch);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 220));
      }
    }

    if (_items.length == target.length &&
        _items.asMap().entries.any((e) => e.value.id != target[e.key].id)) {
      setState(() => _items = List<Character>.from(target));
    }
  }

  void _removeAt(
    int index, {
    bool animate = true,
    bool toggleAlreadyDone = false,
    DismissDirection? dir,
  }) {
    if (index < 0 || index >= _items.length) return;
    final removed = _items.removeAt(index);

    _lastDismissDir[removed.id] = dir ?? DismissDirection.endToStart;

    if (animate) {
      _listKey.currentState?.removeItem(
        index,
        (context, anim) => _buildRemovedItem(removed, anim),
        duration: const Duration(milliseconds: 230),
      );
    } else {
      setState(() {});
    }

    if (!toggleAlreadyDone) {
      favorites.toggle(removed);
    }
  }

  void _removeById(int id, {DismissDirection? dir}) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _removeAt(index, animate: true, toggleAlreadyDone: false, dir: dir);
    }
  }

  Widget _buildRemovedItem(Character ch, Animation<double> anim) {
    final curved = CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic);
    final reverse = ReverseAnimation(curved);

    final dir = _lastDismissDir[ch.id] ?? DismissDirection.endToStart;
    final dx = dir == DismissDirection.startToEnd ? 0.25 : -0.25;

    final slide = Tween<Offset>(begin: Offset.zero, end: Offset(dx, 0))
        .animate(reverse);
    final scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(ReverseAnimation(CurvedAnimation(parent: anim, curve: Curves.easeOut)));
    final fade = CurvedAnimation(parent: anim, curve: const Interval(0.0, 0.85, curve: Curves.easeOut));

    return SizeTransition(
      sizeFactor: anim, 
      axisAlignment: 0.0,
      child: FadeTransition(
        opacity: fade,   
        child: SlideTransition(
          position: slide, 
          child: ScaleTransition(
            scale: scale,  
            child: CharacterCard(
              character: ch,
              isFavorite: true,
              onToggleFavorite: (_) {}, 
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Character ch, int index, Animation<double> anim) {
    final fade = CurvedAnimation(parent: anim, curve: Curves.easeIn);
    final size = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

    return FadeTransition(
      opacity: fade,
      child: SizeTransition(
        sizeFactor: size,
        axisAlignment: -1.0,
        child: Dismissible(
          key: ValueKey('fav_${ch.id}'),
          direction: DismissDirection.horizontal,
          background: _removeBg(context, alignLeft: true),
          secondaryBackground: _removeBg(context, alignLeft: false),
          confirmDismiss: (dir) async {
            _removeById(ch.id, dir: dir);
            return false;
          },
          child: CharacterCard(
            character: ch,
            isFavorite: true,
            onToggleFavorite: (_) {
              _removeById(ch.id, dir: DismissDirection.endToStart);
            },
          ),
        ),
      ),
    );
  }

  Widget _removeBg(BuildContext context, {required bool alignLeft}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.errorContainer.withValues(alpha: 0.35),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!alignLeft)
            Text('Убрать из избранного', style: TextStyle(color: cs.onErrorContainer)),
          const SizedBox(width: 8),
          Icon(Icons.star_outline, color: cs.onErrorContainer),
          if (alignLeft) const SizedBox(width: 8),
          if (alignLeft)
            Text('Убрать из избранного', style: TextStyle(color: cs.onErrorContainer)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              const Text('Сортировка:'),
              const SizedBox(width: 8),
              DropdownButton<FavSort>(
                value: favorites.sort,
                onChanged: (v) => v != null ? favorites.setSort(v) : null,
                items: const [
                  DropdownMenuItem(value: FavSort.nameAsc, child: Text('Имя (A-Z)')),
                  DropdownMenuItem(value: FavSort.nameDesc, child: Text('Имя (Z-A)')),
                  DropdownMenuItem(value: FavSort.status, child: Text('Статус')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('Здесь появятся ваши избранные персонажи'))
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: _items.length,
                  itemBuilder: (context, index, anim) =>
                      _buildItem(_items[index], index, anim),
                ),
        ),
      ],
    );
  }
}