import 'package:cards/models/card_model.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card or a placeholder.
class CardWidget extends StatelessWidget {
  /// Creates a [CardWidget] with a [CardModel] card.
  /// If the card is null, a placeholder is shown.
  CardWidget({
    super.key,
    CardModel? card,
    this.revealed = false,
  }) {
    if (card == null) {
      this.card = CardModel(suit: '?', rank: '?', value: 0);
    } else {
      this.card = card;
    }
  }

  /// The playing card to be displayed.
  late final CardModel card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: revealed
            ? (card.suit == 'Joker' ? surfaceForJoker() : surfaceReveal())
            : surfaceForHidden(),
      ),
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
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Text(
            card.value.toString(),
            style: TextStyle(
              fontSize: 20,
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
    Color color = card.rank == 'Black' ? Colors.black : Colors.red;
    return Stack(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Transform.rotate(
              angle: -45 * 3.14159265 / 180, // Converts degrees to radians
              child: Text(
                'Joker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Text(
            card.value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget surfaceForHidden() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/back_of_card.png'),
          fit: BoxFit.fill, // adjust the fit as needed
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
