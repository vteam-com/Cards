import 'package:flutter/material.dart';

class BlinkWidget extends StatefulWidget {
  const BlinkWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });
  final Widget child;
  final Duration duration;

  @override
  BlinkWidgetState createState() => BlinkWidgetState();
}

class BlinkWidgetState extends State<BlinkWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value, // Use the same animation for scaling
          child: Opacity(
            opacity: _animation.value, // _animation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
