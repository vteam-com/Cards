import 'package:cards/widgets/blink_widget.dart';
import 'package:flutter/material.dart';

class BlinkingTextWidget extends StatelessWidget {
  const BlinkingTextWidget({
    super.key,
    required this.text,
    this.style,
  });
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlinkWidget(
      child: Text(
        textAlign: TextAlign.right,
        text,
        style: style,
      ),
    );
  }
}
