import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.starKey,
  });

  final Character character;
  final bool isFavorite;
  final ValueChanged<Offset?> onToggleFavorite;
  final GlobalKey? starKey;

  Color _statusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final internalKey = starKey ?? GlobalObjectKey('star_${character.id}_${isFavorite ? 1 : 0}');
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: character.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black12),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                fadeInDuration: Duration.zero,     
                fadeOutDuration: Duration.zero,
                useOldImageOnUrlChange: true,     
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              character.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: RepaintBoundary(
                                key: internalKey,
                                child: AnimatedScale(
                                  scale: isFavorite ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 160),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedRotation(
                                    turns: isFavorite ? 0.03 : 0.0,
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOut,
                                    child: IconButton(
                                      iconSize: 28,
                                      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                                      color: isFavorite ? Colors.amber : null,
                                      tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                                      onPressed: () {
                                        final rb = internalKey.currentContext?.findRenderObject() as RenderBox?;
                                        final start = rb?.localToGlobal(rb.size.center(Offset.zero));
                                        onToggleFavorite(start);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: _statusColor(character.status, context)),
                          const SizedBox(width: 6),
                          Text('${character.status} • ${character.species}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      const Spacer(),
                      Text('Локация: ${character.location}', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}