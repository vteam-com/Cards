import 'dart:math';

import 'package:cards/models/game_model.dart';
import 'package:cards/models/player.dart';
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
            Divider(
              color: Colors.white.withAlpha(100),
            ),

            //
            // CTA
            //
            PlayerZoneCTA(
              playerIndex: index,
              isActivePlayer: isActivePlayer,
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
                child: buildPlayerHand(context, gameModel, index),
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
    final bool isVisible = gameModel.cardVisibility[playerIndex][gridIndex];
    final PlayingCard card = gameModel.players[playerIndex].hand[gridIndex];
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
