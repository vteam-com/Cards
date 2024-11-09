import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:cards/widgets/wiggle_widget.dart';
import 'package:flutter/material.dart';

class CardPileWidget extends StatelessWidget {
  const CardPileWidget({
    super.key,
    required this.cards,
    this.onDraw,
    required this.cardsAreHidden,
    required this.wiggleTopCard,
    required this.revealTopDeckCard,
  });

  final List<CardModel> cards;
  final VoidCallback? onDraw;
  final bool cardsAreHidden;
  final bool revealTopDeckCard;
  final bool wiggleTopCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: _buildPileUnplayedCards(), // Build the discard pile
    );
  }

  Widget _buildPileUnplayedCards() {
    return Tooltip(
      message: '${cards.length} cards',
      child: SizedBox(
        width: 140.0,
        child: GestureDetector(
          onTap: onDraw,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(cards.length, (index) {
              double offset =
                  index.toDouble() * 0.5; // Offset for stacking effect
              bool isTopCard = index == cards.length - 1;
              return Positioned(
                left: offset,
                top: offset,
                child: WiggleWidget(
                  wiggle: isTopCard && wiggleTopCard,
                  child: CardWidget(
                    card: cards[index],
                    revealed: revealTopDeckCard && isTopCard,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
