import 'package:cards/models/game_model.dart';
import 'package:cards/widgets/card_pile_widget.dart';
import 'package:cards/widgets/card_piles_widget.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneCtaWidget extends StatelessWidget {
  const PlayerZoneCtaWidget({
    super.key,
    required this.player,
    required this.gameModel,
  });

  final PlayerModel player;
  final GameModel gameModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Center(child: buildContent(context)),
    );
  }

  Widget buildContent(BuildContext context) {
    if (player.isActivePlayer) {
      switch (gameModel.gameState) {
        //
        case GameStates.notStarted:
          return Text('Starting');

        /// Player has to choose to Reveal the Top Deck card or Take the Discarded Card
        /// if chose to reveal deck card >>> [swapWithAnyCardsInHandOrDiscard]
        /// selected the discard card >>> [GameStates.swapDiscardedCardWithAnyCardsInHand]
        case GameStates.pickCardFromEitherPiles:
          return ctaPickCardFromPiles(context);

        // Use has chosen to reveal the top deck card
        // now either:
        // 1) swap with any of the players card > Move to next players [pickCardFromEitherPiles]
        // 2) discard > this will move the state to >>> [revealOneHiddenCard]
        case GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard:
          return ctaSwapTopDeckCardWithAnyCardsInHandOrDiscard();

        // swap the discarded card with any of the players card >>>> Move to next players [pickCardFromEitherPiles]
        case GameStates.swapDiscardedCardWithAnyCardsInHand:
          return ctaSwapDiscardedCardWithAnyCardsInHand();

        // after this it goes to next player >>> [pickCardFromEitherPiles]
        case GameStates.revealOneHiddenCard:
          return ctaFlipOneOfYourHiddenCards();

        //
        case GameStates.gameOver:
          return Text('GAME OVER');
      }
    } else {
      return buildWaitingForTurnContent();
    }
  }

  Widget ctaSwapTopDeckCardWithAnyCardsInHandOrDiscard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: CardPileWidget(
            cards: gameModel.deck.cardsDeckPile,
            wiggleTopCard: false,
            cardsAreHidden: true,
            revealTopDeckCard: true,
          ),
        ),
        buildMiniInstructions(
          true,
          'Discard →\nor\n↓ swap',
          TextAlign.center,
        ),
        FittedBox(
          fit: BoxFit.cover,
          child: CardPileWidget(
            cards: gameModel.deck.cardsDeckDiscarded,
            onDraw: () {
              // Player has discard the top deck revealed card
              // they now have to turn over one of their hidden card
              gameModel.deck.cardsDeckDiscarded
                  .add(gameModel.deck.cardsDeckPile.removeLast());
              gameModel.gameState = GameStates.revealOneHiddenCard;
            },
            cardsAreHidden: false,
            wiggleTopCard: true,
            revealTopDeckCard: true,
          ),
        ),
      ],
    );
  }

  Widget ctaSwapDiscardedCardWithAnyCardsInHand() {
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
          card: gameModel.deck.cardsDeckDiscarded.last,
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
        if (GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard !=
            gameModel.gameState)
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
            //
            // main draw pile
            //
            cardsInDrawPile: gameModel.deck.cardsDeckPile,
            revealTopDeckCard: gameModel.gameState ==
                GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard,
            onPickedFromDrawPile: () {
              gameModel.selectTopCardOfDeck(context, fromDiscardPile: false);
            },
            //
            // discarded pile
            //
            cardsDiscardPile: gameModel.deck.cardsDeckDiscarded,
            onPickedFromDiscardPile: () {
              gameModel.selectTopCardOfDeck(context, fromDiscardPile: true);
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        buildMiniInstructions(
          true,
          'or\nhere\n←',
          TextAlign.right,
        ),
      ],
    );
  }

  Widget buildWaitingForTurnContent() {
    return buildMiniInstructions(
      player.isActivePlayer,
      player.areAllCardsRevealed() ? 'You are done.' : 'Wait for your turn :)',
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
