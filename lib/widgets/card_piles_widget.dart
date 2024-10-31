import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class CardPilesWidget extends StatelessWidget {
  const CardPilesWidget({
    super.key,
    required this.cardsInDrawPile,
    required this.cardsDiscardPile,
    required this.onPickedFromDrawPile,
    required this.onPickedFromDiscardPile,
  });

  final List<CardModel> cardsInDrawPile;
  final List<CardModel> cardsDiscardPile;
  final VoidCallback onPickedFromDrawPile;
  final VoidCallback onPickedFromDiscardPile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
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
    return Tooltip(
      message: '${cardsInDrawPile.length} cards',
      child: SizedBox(
        width: 150,
        child: GestureDetector(
          onTap: onPickedFromDrawPile,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(cardsInDrawPile.length, (index) {
              double offset = index * 0.5; // Offset for stacking effect
              return Positioned(
                left: offset,
                top: offset,
                child: CardWidget(
                  card: cardsInDrawPile[index],
                  revealed: false,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPileDiscard() {
    return Tooltip(
      message: '${cardsDiscardPile.length} cards',
      child: SizedBox(
        width: 150, // Adjust the width based on the discard pile size
        child: GestureDetector(
          onTap: onPickedFromDiscardPile,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(cardsDiscardPile.length, (index) {
              double offset = index * 0.5; // Offset for stacking effect
              return Positioned(
                left: offset,
                top: offset,
                child: CardWidget(
                  card: cardsDiscardPile[index],
                  revealed: true,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
