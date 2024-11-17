import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/wiggle_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card or a placeholder.
///
/// The [CardWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses the [WiggleWidget] to provide a wiggling animation when the card is selectable. It also adjusts the opacity of the card based on its selectable state.
///
/// The card surface is rendered using different methods depending on the card's properties, such as whether it is a Joker card or a regular card with suit and rank.
class CardWidget extends StatelessWidget {
  /// Creates a [CardWidget] with a [CardModel] card.
  /// If the card is null, a placeholder is shown.
  const CardWidget({
    super.key,
    required this.card,
  });

  /// The playing card to be displayed.
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return WiggleWidget(
      wiggle: card.isSelectable,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          margin: const EdgeInsets.all(CardDimensions.margin),
          width: CardDimensions.width,
          height: CardDimensions.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: card.isRevealed ? _buildFaceUp() : _buildFaceDown(),
        ),
      ),
    );
  }

  /// Builds a widget for displaying a regular card with suit and rank.
  Widget _buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Column(
            children: [
              _buildRank(),
              const Spacer(),
              _buildValue(),
            ],
          ),

          //
          // Display the center representation of the Suite & Card
          //
          ..._buildSuitSymbols(),
        ],
      ),
    );
  }

  Widget _buildRank() {
    final color = _getSuitColor(card.suit);
    switch (card.rank) {
      case '§':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joker',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        );
      case 'K':
      case 'Q':
      case 'J':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.rank,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              card.suit,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              card.rank,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          card.value.toString(),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getSuitColor(card.suit),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceDown() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/back_of_card.png'),
          fit: BoxFit.fill, // adjust the fit as needed
        ),
      ),
    );
  }

  Widget _buildSuitSymbol({final double size = 18}) {
    return Text(
      card.suit,
      style: TextStyle(
        fontSize: size,
        color: _getSuitColor(card.suit),
      ),
    );
  }

  List<Widget> _buildSuitSymbols() {
    List<Widget> symbols = [];
    int numSymbols = card.value;

    List<Offset> positions;
    switch (numSymbols) {
      case -2: // Joker
        return [_figureCards('⛳')];
      case 0: // King
        return [_figureCards('♚')];
      case 12: // Queen
        return [_figureCards('♛')];
      case 11: // Jack
        return [_figureCards('♝')];

      case 1:
        return [Center(child: _buildSuitSymbol(size: 30))];

      // Layout for number cards 2 to 10
      case 2:
        positions = [Offset(0, -30), Offset(0, 30)];
        break;
      case 3:
        positions = [
          Offset(0, -30),
          Offset(0, 0),
          Offset(0, 30),
        ];
        break;
      case 4:
        positions = [
          Offset(-20, -20),
          Offset(20, -20),
          Offset(-20, 20),
          Offset(20, 20),
        ];
        break;
      case 5:
        positions = [
          // top
          Offset(0, 0),

          // left
          Offset(-20, -20),
          Offset(-20, 20),

          // right
          Offset(20, -20),
          Offset(20, 20),
        ];
        break;
      case 6:
        positions = [
          // left column
          Offset(-15, -30),
          Offset(-15, 0),
          Offset(-15, 30),

          // right column
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 7:
        positions = [
          // left
          Offset(-20, -30),
          Offset(-20, 0),
          Offset(-20, 30),
          // center
          Offset(0, 0),
          // right
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 8:
        positions = [
          // top row
          Offset(-20, -30),
          Offset(20, -30),
          // second
          Offset(-20, -10),
          Offset(20, -10),
          // third
          Offset(-20, 10),
          Offset(20, 10),
          // last
          Offset(-20, 30),
          Offset(20, 30),
        ];
        break;
      case 9:
        positions = [
          // left
          Offset(-20, -30),
          Offset(-20, 0),
          Offset(-20, 30),
          // center
          Offset(0, -30),
          Offset(0, 0),
          Offset(0, 30),
          // right
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 10:
        positions = [
          // Left column
          Offset(-20, -30),
          Offset(-20, -10),
          Offset(-20, 10),
          Offset(-20, 30),
          Offset(-20, 50),

          // right column
          Offset(20, -50),
          Offset(20, -30),
          Offset(20, -10),
          Offset(20, 10),
          Offset(20, 30),
        ];
        break;
      default:
        positions = [];
    }

    for (final Offset position in positions) {
      symbols.add(
        Positioned(
          left: 35 + position.dx, // Adjust 50 to center horizontally
          top: 70 + position.dy, // Adjust 75 to center vertically
          child: _buildSuitSymbol(),
        ),
      );
    }

    return symbols;
  }

  Widget _figureCards(final String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: _getSuitColor(card.suit), fontSize: 60),
        ),
      ),
    );
  }

  /// Returns the color associated with the suit string.
  Color _getSuitColor(String suit) {
    switch (suit) {
      case '♥️':
      case '♦️':
        return Colors.red;
      case '♣️':
      case '♠️':
        return Colors.black;
      default:
        return Colors.green;
    }
  }
}

enum CardType { joker, numbered, face, hidden }

// Move to a separate constants file or class
class CardDimensions {
  static const double width = 100.0;
  static const double height = 150.0;
  static const double margin = 4.0;
  static const double borderRadius = 4.0;
}
