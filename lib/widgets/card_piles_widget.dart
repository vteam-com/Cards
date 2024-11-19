import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/card_pile_widget.dart';
import 'package:flutter/material.dart';

class CardPilesWidget extends StatelessWidget {
  const CardPilesWidget({
    super.key,
    required this.cardsInDrawPile,
    required this.cardsDiscardPile,
    required this.onPickedFromDrawPile,
    required this.onPickedFromDiscardPile,
    required this.revealTopDeckCard,
    required this.onDragDropped,
  });

  final List<CardModel> cardsInDrawPile;
  final List<CardModel> cardsDiscardPile;
  final VoidCallback onPickedFromDrawPile;
  final VoidCallback onPickedFromDiscardPile;
  final bool revealTopDeckCard;
  final Function(CardModel source, CardModel target) onDragDropped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //
          // Deck pile
          //
          CardPileWidget(
            cards: cardsInDrawPile,
            cardsAreHidden: true,
            onDraw: onPickedFromDrawPile,
            revealTopDeckCard: revealTopDeckCard,
            wiggleTopCard: !revealTopDeckCard,
            isDropSource: true,
            isDropTarget: false,
            onDragDropped: onDragDropped,
          ),
          // Gap
          SizedBox(
            width: 8,
          ),
          //
          // Discarded pile
          //
          CardPileWidget(
            cards: cardsDiscardPile,
            cardsAreHidden: false,
            onDraw: onPickedFromDiscardPile,
            revealTopDeckCard: true,
            wiggleTopCard: !revealTopDeckCard,
            isDropSource: !revealTopDeckCard,
            isDropTarget: revealTopDeckCard,
            onDragDropped: onDragDropped,
          ),
        ],
      ),
    );
  }
}
