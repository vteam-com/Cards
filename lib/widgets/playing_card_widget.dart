import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card or a placeholder.
class PlayingCardWidget extends StatelessWidget {
  /// Creates a [PlayingCardWidget] with a [PlayingCard] card.
  /// If the card is null, a placeholder is shown.
  const PlayingCardWidget({
    super.key,
    required this.card,
    this.revealed = false,
  });

  /// The playing card to be displayed.
  final PlayingCard card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black.withAlpha(200), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: revealed
          ? (card.suit == 'Joker' ? surfaceForJoker() : surfaceReveal())
          : surfaceForHidden(),
    );
  }

  /// Builds a widget for displaying a regular card with suit and rank.
  Widget surfaceReveal() {
    return Stack(
      children: [
        Positioned(
          top: 4,
          left: 4,
          child: Text(
            card.rank,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Text(
            card.rank,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
        ),
        Center(
          child: Text(
            _getSuitSymbol(card.suit),
            style: TextStyle(
              fontSize: 20,
              color: _getSuitColor(card.suit),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a widget for displaying a Joker card.
  Widget surfaceForJoker() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform.rotate(
          angle: -45 * 3.14159265 / 180, // Converts degrees to radians
          child: Text(
            'Joker',
            style: TextStyle(
              fontSize: 24,
              color: card.rank == 'Black' ? Colors.black : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget surfaceForHidden() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/back_of_card.png'),
          fit: BoxFit.cover, // adjust the fit as needed
        ),
      ),
    );
  }

  /// Returns the suit symbol based on the suit string.
  String _getSuitSymbol(String suit) {
    switch (suit) {
      case 'Hearts':
        return '♥️';
      case 'Diamonds':
        return '♦️';
      case 'Clubs':
        return '♣️';
      case 'Spades':
        return '♠️';
      default:
        return '';
    }
  }

  /// Returns the color associated with the suit string.
  Color _getSuitColor(String suit) {
    switch (suit) {
      case 'Hearts':
      case 'Diamonds':
        return Colors.red;
      case 'Clubs':
      case 'Spades':
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}
