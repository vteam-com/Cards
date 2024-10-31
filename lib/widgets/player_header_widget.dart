import 'package:flutter/material.dart';

class PlayerHeaderWidget extends StatelessWidget {
  const PlayerHeaderWidget({
    super.key,
    required this.name,
    required this.sumOfRevealedCards,
  });
  final String name;
  final int sumOfRevealedCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sumOfRevealedCards.toString(),
          style: TextStyle(
            color: Colors.white.withAlpha(150),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
