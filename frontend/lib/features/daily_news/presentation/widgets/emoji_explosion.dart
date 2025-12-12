import 'dart:math';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// A widget that displays an explosion animation of emojis rising up the screen.
///
/// Features:
/// - Multiple emoji particles with varying sizes and speeds
/// - Physics-based motion with gravity and random trajectories
/// - Fade out as particles rise
/// - Professional, modern animation feel
class EmojiExplosion extends StatefulWidget {
  /// The reaction type to animate.
  final ArticleReaction reaction;
  
  /// Starting position of the explosion (typically where the user tapped).
  final Offset startPosition;
  
  /// Callback when the animation completes.
  final VoidCallback? onComplete;
  
  /// Number of emoji particles to spawn.
  final int particleCount;

  const EmojiExplosion({
    super.key,
    required this.reaction,
    required this.startPosition,
    this.onComplete,
    this.particleCount = 12,
  });

  @override
  State<EmojiExplosion> createState() => _EmojiExplosionState();
}

class _EmojiExplosionState extends State<EmojiExplosion>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_EmojiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _particles = _generateParticles();
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  List<_EmojiParticle> _generateParticles() {
    return List.generate(widget.particleCount, (index) {
      // Random horizontal spread
      final spreadAngle = (_random.nextDouble() - 0.5) * pi * 0.8;
      // Random initial velocity
      final speed = 300 + _random.nextDouble() * 400;
      // Random size variation
      final size = 20.0 + _random.nextDouble() * 16;
      // Random rotation
      final rotation = _random.nextDouble() * 2 * pi;
      final rotationSpeed = (_random.nextDouble() - 0.5) * 4;
      // Staggered start delay (0 to 100ms)
      final delay = _random.nextDouble() * 0.1;
      
      return _EmojiParticle(
        initialVelocityX: sin(spreadAngle) * speed,
        initialVelocityY: -cos(spreadAngle.abs()) * speed - 200,
        size: size,
        initialRotation: rotation,
        rotationSpeed: rotationSpeed,
        startDelay: delay,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            return _buildParticle(particle);
          }).toList(),
        );
      },
    );
  }

  Widget _buildParticle(_EmojiParticle particle) {
    // Adjust time for particle's individual delay
    final adjustedTime = ((_controller.value - particle.startDelay) / 
        (1 - particle.startDelay)).clamp(0.0, 1.0);
    
    if (adjustedTime <= 0) {
      return const SizedBox.shrink();
    }
    
    // Apply easing curves
    final easedTime = Curves.easeOutQuart.transform(adjustedTime);
    final fadeTime = Curves.easeIn.transform(adjustedTime);
    
    // Physics calculations
    const gravity = 400.0; // Reduced gravity for longer float
    final time = adjustedTime * 1.5; // Time in seconds
    
    // Position with gravity
    final dx = particle.initialVelocityX * time;
    final dy = particle.initialVelocityY * time + 0.5 * gravity * time * time;
    
    // Scale: start big, shrink slightly
    final scale = 1.0 + (1.0 - easedTime) * 0.3;
    
    // Opacity: fade out as it rises
    final opacity = (1.0 - fadeTime * 0.8).clamp(0.0, 1.0);
    
    // Rotation
    final rotation = particle.initialRotation + 
        particle.rotationSpeed * adjustedTime * 2;
    
    return Positioned(
      left: widget.startPosition.dx + dx - particle.size / 2,
      top: widget.startPosition.dy + dy - particle.size / 2,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Text(
              widget.reaction.emoji,
              style: TextStyle(
                fontSize: particle.size,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal class representing a single emoji particle's properties.
class _EmojiParticle {
  final double initialVelocityX;
  final double initialVelocityY;
  final double size;
  final double initialRotation;
  final double rotationSpeed;
  final double startDelay;

  const _EmojiParticle({
    required this.initialVelocityX,
    required this.initialVelocityY,
    required this.size,
    required this.initialRotation,
    required this.rotationSpeed,
    required this.startDelay,
  });
}

/// Overlay entry manager for emoji explosion animations.
///
/// Use this to easily trigger explosion animations from anywhere in the app.
class EmojiExplosionOverlay {
  static final List<OverlayEntry> _activeEntries = [];

  /// Triggers an emoji explosion animation at the given position.
  ///
  /// [context] - BuildContext to insert the overlay
  /// [reaction] - The reaction type to animate
  /// [position] - Global position to start the explosion from
  static void show({
    required BuildContext context,
    required ArticleReaction reaction,
    required Offset position,
    int particleCount = 12,
  }) {
    final overlay = Overlay.of(context);
    
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => EmojiExplosion(
        reaction: reaction,
        startPosition: position,
        particleCount: particleCount,
        onComplete: () {
          entry.remove();
          _activeEntries.remove(entry);
        },
      ),
    );
    
    _activeEntries.add(entry);
    overlay.insert(entry);
  }

  /// Removes all active explosion animations.
  static void clearAll() {
    for (final entry in _activeEntries) {
      entry.remove();
    }
    _activeEntries.clear();
  }
}
