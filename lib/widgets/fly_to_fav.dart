import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlyToFav {
  
  static Future<void> runFromPoint({
    required BuildContext overlayContext, 
    required Offset start,                
    required GlobalKey targetKey,         
    Color color = Colors.amber,
    double size = 26,
    Duration duration = const Duration(milliseconds: 650),
    int tailCount = 8,           
    double tailSpacing = 0.06,   
  }) async {
    
    final overlayState = Overlay.maybeOf(overlayContext, rootOverlay: true);
    if (overlayState == null) return;

    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    final Offset end =
        targetBox.localToGlobal(targetBox.size.center(Offset.zero));

    
    final control = Offset(
      (start.dx + end.dx) / 2,
      math.max(start.dy, end.dy) + 160,
    );

    Offset bezier(double t) {
      final x = (1 - t) * (1 - t) * start.dx +
          2 * (1 - t) * t * control.dx +
          t * t * end.dx;
      final y = (1 - t) * (1 - t) * start.dy +
          2 * (1 - t) * t * control.dy +
          t * t * end.dy;
      return Offset(x, y);
    }

    final Size screenSize = MediaQuery.of(overlayContext).size;

    final entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: duration,
            curve: Curves.easeInOutCubic,
            builder: (context, t, __) {
              final children = <Widget>[];

              for (int i = 1; i <= tailCount; i++) {
                final tt = t - i * tailSpacing;
                if (tt <= 0) continue;
                final pos = bezier(tt.clamp(0.0, 1.0));
                final k = 1 - (i / (tailCount + 1)); // 0..1
                final tailSize =
                    (size * (0.65 * k + 0.15)).clamp(8.0, size);
                final alpha = (0.15 + 0.55 * k).clamp(0.0, 1.0);

                children.add(Positioned(
                  left: pos.dx - tailSize / 2,
                  top: pos.dy - tailSize / 2,
                  child: Icon(
                    Icons.star,
                    size: tailSize,
                    color: color.withValues(alpha: alpha),
                  ),
                ));
              }

              final pos = bezier(t);
              final opacity =
                  t < 0.9 ? 1.0 : (1.0 - (t - 0.9) / 0.1).clamp(0.0, 1.0);
              final scale = 1.1 - 0.25 * t;

              children.add(Positioned(
                left: pos.dx - size / 2,
                top: pos.dy - size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(Icons.star, color: color, size: size),
                  ),
                ),
              ));

              return Stack(children: children);
            },
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    await Future.delayed(duration);
    entry.remove();
  }
}