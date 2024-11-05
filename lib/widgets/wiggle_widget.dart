import 'dart:math';

import 'package:flutter/material.dart';

class WiggleWidget extends StatefulWidget {
  const WiggleWidget({super.key, required this.child, this.wiggle = true});
  final Widget child;
  final bool wiggle;

  @override
  WiggleWidgetState createState() => WiggleWidgetState();
}

class WiggleWidgetState extends State<WiggleWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _wiggleAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    if (widget.wiggle) {
      // Initialize the animation controller
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ); // Repeat the animation back and forth

      _controller!.value = _random.nextDouble();
      _controller!.repeat(reverse: true);

      // Define the wiggle animation with a slight rotation angle
      _wiggleAnimation = Tween<double>(begin: -0.03, end: 0.04).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller
        ?.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wiggle) {
      return AnimatedBuilder(
        animation: _wiggleAnimation!,
        builder: (context, child) {
          return Transform.rotate(
            angle: _wiggleAnimation!.value,
            child: child,
          );
        },
        child: widget.child,
      );
    } else {
      // just display as is
      return widget.child;
    }
  }
}
