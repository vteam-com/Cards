import 'package:cards/models/game_model.dart';
import 'package:cards/widgets/card_pile_widget.dart';
import 'package:cards/widgets/card_piles_widget.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneCtaWidget extends StatelessWidget {
  const PlayerZoneCtaWidget({
    super.key,
    required this.playerIndex,
    required this.isActivePlayer,
    required this.gameModel,
  });
  final int playerIndex;
  final bool isActivePlayer;
  final GameModel gameModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Center(child: buildContent(context)),
    );
  }

  Widget buildContent(BuildContext context) {
    if (isActivePlayer) {
      switch (gameModel.gameState) {
        case GameStates.keepOrDiscard:
          return ctaSwapOrDiscard();
        case GameStates.flipAndSwap:
          return ctaSwapWithKeptCard();
        case GameStates.flipOneCard:
          return ctaFlipOneOfYourHiddenCards();
        case GameStates.pickCardFromPiles:
        default:
          return ctaPickCardFromPiles(context);
      }
    } else {
      return buildWaitingForTurnContent();
    }
  }

  Widget ctaSwapOrDiscard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: CardWidget(
            card: gameModel.selectedCard!,
            revealed: true,
          ),
        ),
        buildMiniInstructions(
          true,
          GameStates.keepOrDiscard == gameModel.gameState
              ? 'Discard →\nor\n↓ swap'
              : 'or\nhere\n←',
          TextAlign.center,
        ),
        FittedBox(
          fit: BoxFit.cover,
          child: CardPileWidget(
            cards: gameModel.deck.cardsDeckDiscarded,
            onDraw: () {
              gameModel.deck.cardsDeckDiscarded.add(gameModel.selectedCard!);
              gameModel.selectedCard = null;
              gameModel.gameState = GameStates.flipOneCard;
            },
            cardsAreHidden: false,
            wiggleTopCard: true,
            revealTopDeckCard: true,
          ),
        ),
      ],
    );
  }

  Widget ctaSwapWithKeptCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildMiniInstructions(
          true,
          'Tap any of your ↓ cards\nto swap with this →',
          TextAlign.center,
        ),
        const SizedBox(
          width: 10,
        ),
        CardWidget(
          card: gameModel.selectedCard,
          revealed: true,
        ),
      ],
    );
  }

  Widget ctaFlipOneOfYourHiddenCards() {
    return buildMiniInstructions(
      true,
      'Flip open one of your hidden cards',
      TextAlign.center,
    );
  }

  Widget ctaPickCardFromPiles(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (GameStates.keepOrDiscard != gameModel.gameState)
          buildMiniInstructions(
            true,
            'Draw\na card\nhere\n→',
            TextAlign.left,
          ),
        const SizedBox(
          width: 10,
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CardPilesWidget(
            cardsInDrawPile: gameModel.deck.cardsDeckPile,
            revealTopDeckCard: gameModel.gameState == GameStates.keepOrDiscard,
            cardsDiscardPile: gameModel.deck.cardsDeckDiscarded,
            onPickedFromDrawPile: () {
              gameModel.drawCard(context, fromDiscardPile: false);
            },
            onPickedFromDiscardPile: () {
              gameModel.drawCard(context, fromDiscardPile: true);
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        buildMiniInstructions(
          true,
          GameStates.keepOrDiscard == gameModel.gameState
              ? '← Discard\nor\n↓ swap'
              : 'or\nhere\n←',
          TextAlign.right,
        ),
      ],
    );
  }

  Widget buildWaitingForTurnContent() {
    return buildMiniInstructions(
      isActivePlayer,
      gameModel.areAllCardRevealed(playerIndex)
          ? 'You are done.'
          : 'Wait for your turn :)',
      TextAlign.center,
    );
  }
}

Widget buildMiniInstructions(
  bool isActivePlayer,
  String text,
  TextAlign align,
) {
  final TextStyle style = TextStyle(
    fontSize: 18,
    color: Colors.white.withAlpha(isActivePlayer ? 255 : 140),
  );

  return Text(text, textAlign: align, style: style);
}
