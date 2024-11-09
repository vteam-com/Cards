import 'dart:math';
import 'package:cards/models/game_model.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:cards/widgets/player_header_widget.dart';
import 'package:cards/widgets/player_zone_cta_widget.dart';
import 'package:cards/widgets/wiggle_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneWidget extends StatelessWidget {
  const PlayerZoneWidget({
    super.key,
    required this.gameModel,
    required this.indexOfPlayer,
    required this.smallDevice,
  });
  final GameModel gameModel;
  final int indexOfPlayer;
  final bool smallDevice;
  bool get isPlayerPlaying => gameModel.playerIdPlaying == indexOfPlayer;

  @override
  Widget build(BuildContext context) {
    final PlayerModel player = gameModel.players[indexOfPlayer];

    return Container(
      width: min(400, MediaQuery.of(context).size.width),
      padding: EdgeInsets.all(smallDevice ? 8 : 20),
      decoration: BoxDecoration(
        color: Colors.green.shade800.withAlpha(100),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isPlayerPlaying ? Colors.yellow : Colors.transparent,
          width: isPlayerPlaying ? 4.0 : 12.0,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
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
              playerIndex: indexOfPlayer,
              isActivePlayer: isPlayerPlaying,
              gameModel: gameModel,
            ),
            Divider(
              color: Colors.white.withAlpha(100),
            ),

            //
            // Cards in Hand
            //
            SizedBox(
              height: smallDevice ? 380 : null,
              child: FittedBox(
                fit: BoxFit.cover,
                child: buildPlayerHand(context, gameModel, indexOfPlayer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlayerHand(
    BuildContext context,
    GameModel gameModel,
    int playerIndex,
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
                    playerIndex,
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
                    playerIndex,
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
                    playerIndex,
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
    int playerIndex,
    int gridIndex,
  ) {
    final bool isVisible =
        gameModel.players[playerIndex].hand[gridIndex].isRevealed;
    final CardModel card = gameModel.players[playerIndex].hand[gridIndex];
    return WiggleWidget(
      wiggle: isPlayerPlaying &&
          (gameModel.gameState ==
                  GameStates.swapDiscardedCardWithAnyCardsInHand ||
              gameModel.gameState ==
                  GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
              (gameModel.gameState == GameStates.revealOneHiddenCard &&
                  !isVisible)),
      child: GestureDetector(
        onTap: () {
          gameModel.revealCard(context, playerIndex, gridIndex);
        },
        child: CardWidget(
          card: card,
          revealed: isVisible,
        ),
      ),
    );
  }
}
