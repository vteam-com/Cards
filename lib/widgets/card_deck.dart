import 'package:cards/widgets/playing_card.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:flutter/material.dart';

class DeckOfCards extends StatelessWidget {
  const DeckOfCards({
    super.key,
    required this.cardsInDeck,
    required this.cardsDiscarded, // List of open cards
    required this.onDrawCard,
    required this.onDrawDiscardedCard,
  });

  final List<PlayingCard> cardsInDeck;
  final List<PlayingCard> cardsDiscarded;
  final VoidCallback onDrawCard;
  final VoidCallback onDrawDiscardedCard;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPileUnplayedCards(),
          _buildPileDiscard(), // Build the discard pile
        ],
      ),
    );
  }

  Widget _buildPileUnplayedCards() {
    return SizedBox(
      width: 150,
      child: GestureDetector(
        onTap: onDrawCard,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(cardsInDeck.length, (index) {
            double offset = index * 0.5; // Offset for stacking effect
            return Positioned(
              left: offset,
              top: offset,
              child: PlayingCardWidget(
                card: cardsInDeck[index],
                revealed: false,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPileDiscard() {
    return SizedBox(
      width: 150, // Adjust the width based on the discard pile size
      child: GestureDetector(
        onTap: onDrawDiscardedCard,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(cardsDiscarded.length, (index) {
            double offset = index * 0.5; // Offset for stacking effect
            return Positioned(
              left: offset,
              top: offset,
              child: PlayingCardWidget(
                card: cardsDiscarded[index],
                revealed: true,
              ),
            );
          }),
        ),
      ),
    );
  }
}
