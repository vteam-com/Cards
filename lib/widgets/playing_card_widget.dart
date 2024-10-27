import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card or a placeholder.
class PlayingCardWidget extends StatelessWidget {
  /// Creates a [PlayingCardWidget] with a [PlayingCard] card.
  /// If the card is null, a placeholder is shown.
  const PlayingCardWidget({super.key, required this.card});

  /// The playing card to be displayed.
  final PlayingCard? card;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: card == null ? null : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: card == null ? null : Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: card == null
          ? _buildPlaceHolder()
          : card!.suit == 'Joker'
              ? _buildJoker()
              : _buildRegularCard(),
    );
  }

  /// Builds a widget for displaying a regular card with suit and rank.
  Widget _buildRegularCard() {
    return Stack(
      children: [
        Positioned(
          top: 4,
          left: 4,
          child: Text(
            card!.rank,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card!.suit),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Text(
            card!.rank,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card!.suit),
            ),
          ),
        ),
        Center(
          child: Text(
            _getSuitSymbol(card!.suit),
            style: TextStyle(
              fontSize: 15,
              color: _getSuitColor(card!.suit),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a placeholder for when the card data is not available.
  Widget _buildPlaceHolder() {
    return const Center(
      child: Text(
        '',
        style: TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds a widget for displaying a Joker card.
  Widget _buildJoker() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform.rotate(
          angle: -45 * 3.14159265 / 180, // Converts degrees to radians
          child: Text(
            'Joker',
            style: TextStyle(
              fontSize: 24,
              color: card!.rank == 'Black' ? Colors.black : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
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

class HiddenCardWidget extends StatelessWidget {
  const HiddenCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 60.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.question_mark, color: Colors.white),
      ),
    );
  }
}
