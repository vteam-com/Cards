import 'package:cards/widgets/playing_card.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:flutter/material.dart';

class DeckOfCards extends StatelessWidget {
  const DeckOfCards({
    super.key,
    required this.cardsInTheDeck,
    required this.discardedCards, // List of open cards
    required this.onDrawCard,
    required this.onDrawDiscardedCard,
  });

  final int cardsInTheDeck;
  final List<PlayingCard>
      discardedCards; // Updated to handle a list of all open cards
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
          children: List.generate(cardsInTheDeck, (index) {
            double offset = index * 0.5; // Offset for stacking effect
            return Positioned(
              left: offset,
              top: offset,
              child: buildBackOfCard(),
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
          children: List.generate(discardedCards.length, (index) {
            double offset = index * 0.5; // Offset for stacking effect
            return Positioned(
              left: offset,
              top: offset,
              child: PlayingCardWidget(card: discardedCards[index]),
            );
          }),
        ),
      ),
    );
  }
}
