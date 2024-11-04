import 'package:cards/widgets/blink_widget.dart';
import 'package:flutter/material.dart';

class BlinkingTextWidget extends StatelessWidget {
  const BlinkingTextWidget({
    super.key,
    required this.text,
    required this.align,
    this.style,
  });
  final String text;
  final TextStyle? style;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return BlinkWidget(
      child: Text(
        textAlign: align,
        text,
        style: style,
      ),
    );
  }
}
