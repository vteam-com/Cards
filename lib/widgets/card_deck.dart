import 'package:cards/widgets/playing_card.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:flutter/material.dart';

class DeckOfCards extends StatelessWidget {
  const DeckOfCards({
    super.key,
    required this.cardsInTheDeck,
    required this.discardedCards, // List of open cards
    required this.onDrawCard,
  });

  final int cardsInTheDeck;
  final List<PlayingCard>
      discardedCards; // Updated to handle a list of all open cards
  final VoidCallback onDrawCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPileUnplayedCards(),
        _buildPileDiscard(), // Build the discard pile
      ],
    );
  }

  Widget _buildPileUnplayedCards() {
    return SizedBox(
      height: 400,
      width: 200,
      child: GestureDetector(
        onTap: onDrawCard,
        child: Stack(
          children: List.generate(cardsInTheDeck, (index) {
            double offset = index * 0.5; // Offset for stacking effect
            return Positioned(
              left: offset,
              top: offset,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.deck, size: 50, color: Colors.white),
                    Text(
                      '$cardsInTheDeck cards',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPileDiscard() {
    return SizedBox(
      width: 400, // Adjust the width based on the discard pile size
      height: 200,
      child: Stack(
        children: List.generate(discardedCards.length, (index) {
          double offset = index * 0.5; // Offset for stacking effect
          return Positioned(
            left: offset,
            top: offset,
            child: PlayingCardWidget(card: discardedCards[index]),
          );
        }),
      ),
    );
  }
}
