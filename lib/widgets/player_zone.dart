import 'dart:math';

import 'package:cards/game_model.dart';
import 'package:cards/player.dart';
import 'package:cards/widgets/player_header.dart';
import 'package:cards/widgets/player_zone_cta.dart';
import 'package:cards/widgets/playing_card.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:flutter/material.dart';

class PlayerZone extends StatelessWidget {
  const PlayerZone({
    super.key,
    required this.gameModel,
    required this.index,
    required this.smallDevice,
  });
  final GameModel gameModel;
  final int index;
  final bool smallDevice;

  @override
  Widget build(BuildContext context) {
    final bool isActivePlayer = gameModel.currentPlayerIndex == index;
    final Player player = gameModel.players[index];
    player.score = gameModel.calculatePlayerScore(index);

    return Container(
      width: min(400, MediaQuery.of(context).size.width),
      padding: EdgeInsets.all(smallDevice ? 8 : 20),
      decoration: BoxDecoration(
        color: Colors.green.shade800.withAlpha(100),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isActivePlayer ? Colors.yellow : Colors.transparent,
          width: isActivePlayer ? 4.0 : 12.0,
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
            PlayerHeader(name: player.name, score: player.score),

            // gap
            SizedBox(height: smallDevice ? 0 : 20),

            //
            // Cards in Hand
            //
            buildPlayerHand(context, gameModel, index, smallDevice),

            //
            // CTA
            //
            FittedBox(
              fit: BoxFit.contain,
              child: PlayerZoneCTA(
                playerIndex: index,
                isActivePlayer: isActivePlayer,
                gameModel: gameModel,
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
    bool squareCards,
  ) {
    final List<PlayingCard> playerHand = gameModel.playerHands[playerIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns is 3
            // Aspect ratio of each grid item
            // recalculate or square aspect ratio
            childAspectRatio: (squareCards ? 1 : 0.75),
          ),
          itemCount: playerHand.length,
          itemBuilder: (context, cardIndex) {
            return buildPlayerCardButton(
              context,
              gameModel,
              playerIndex,
              cardIndex,
            );
          },
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
    final bool isVisible = gameModel.cardVisibility[playerIndex][gridIndex];
    final PlayingCard card = gameModel.playerHands[playerIndex][gridIndex];
    return GestureDetector(
      onTap: () {
        gameModel.revealCard(context, playerIndex, gridIndex);
      },
      child: PlayingCardWidget(
        card: card,
        revealed: isVisible,
      ),
    );
  }
}
