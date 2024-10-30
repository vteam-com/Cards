import 'package:cards/widgets/blink.dart';
import 'package:flutter/material.dart';

class BlinkingText extends StatelessWidget {
  const BlinkingText({
    super.key,
    required this.text,
    this.style,
  });
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Blink(
      child: Text(
        textAlign: TextAlign.right,
        text,
        style: style,
      ),
    );
  }
}
