// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

/// A custom circular glass-like button with blur and ripple effects.
///
/// This widget displays a circular button with a glassmorphic (frosted glass) appearance,
/// including a blurred background, border, gradient, and ripple effect on tap.
/// The child widget is centered inside the button.
class MyButton extends StatelessWidget {
  /// Creates a [MyButton].
  ///
  /// [onTap] is called when the button is tapped.
  /// [child] is the widget displayed inside the button.
  /// [size] determines the diameter of the button (default is 44).
  /// [padding] adds padding around the button (default is [EdgeInsets.all(0)]).
  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 44,
    this.padding = const EdgeInsets.all(0),
  });

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// The diameter of the circular button.
  final double size;

  /// The widget displayed at the center of the button.
  final Widget child;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Blur whatever is behind the button
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: const SizedBox.shrink(),
              ),
              // Glassy layer
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.8),
                    ),
                    BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(-2, -2),
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              // Ink ripple
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(0.25),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Center(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
