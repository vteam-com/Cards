import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/models/misc.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:cards/widgets/player_header_widget.dart';
import 'package:cards/widgets/player_zone_cta_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneWidget extends StatelessWidget {
  const PlayerZoneWidget({
    super.key,
    required this.gameModel,
    required this.player,
    this.height = 750,
    this.cardHeight = 400,
  });
  final GameModel gameModel;
  final PlayerModel player;
  final double height;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    debugLog(player.toString());
    final double width = min(400, MediaQuery.of(context).size.width);
    return Stack(
      children: [
        if (player.isActivePlayer)
          FadeIn(
            child: containerBorder(width, height),
          ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.green.shade800.withAlpha(50),
            border: Border.all(
              color: Colors.transparent,
              width: 8,
            ),
            borderRadius: BorderRadius.circular(20.0),
            // No shadow.
          ),
          padding: EdgeInsets.all(10),
          child: buildContent(context),
        ),
      ],
    );
  }

  Widget containerBorder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.yellow,
          width: 8,
        ),
        borderRadius: BorderRadius.circular(20.0),
        // No shadow.
      ),
    );
  }

  LinearGradient activeBorder() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.yellow.shade200,
        Colors.yellow.shade700,
      ],
    );
  }

  Widget buildContent(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //
        // Header
        //
        PlayerHeaderWidget(
          name: player.name,
          sumOfRevealedCards: player.sumOfRevealedCards,
        ),
        Divider(
          color: Colors.white.withAlpha(100),
        ),

        //
        // CTA
        //
        PlayerZoneCtaWidget(
          player: player,
          gameModel: gameModel,
        ),
        Divider(
          color: Colors.white.withAlpha(100),
        ),

        //
        // Cards in Hand
        //
        SizedBox(
          height: cardHeight,
          child: FittedBox(
            fit: BoxFit.cover,
            child: buildPlayerHand(
              context,
              gameModel,
              player,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPlayerHand(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [0, 1, 2].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
            Row(
              children: [3, 4, 5].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
            Row(
              children: [6, 7, 8].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget buildPlayerCardButton(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
    int gridIndex,
  ) {
    final CardModel card = player.hand[gridIndex];

    card.isRevealed = player.hand[gridIndex].isRevealed;

    card.isSelectable = player.isActivePlayer &&
        (gameModel.gameState ==
                GameStates.swapDiscardedCardWithAnyCardsInHand ||
            gameModel.gameState ==
                GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
            (gameModel.gameState == GameStates.revealOneHiddenCard &&
                !card.isRevealed));

    return GestureDetector(
      onTap: () {
        gameModel.revealCard(context, player, gridIndex);
      },
      child: CardWidget(card: card),
    );
  }
}
