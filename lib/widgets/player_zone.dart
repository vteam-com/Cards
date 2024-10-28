import 'package:cards/game_model.dart';
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
  });
  final GameModel gameModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    final playerName = gameModel.playerNames[index];
    final playerScore = gameModel.calculatePlayerScore(index);
    final isActivePlayer = gameModel.currentPlayerIndex == index;

    return Container(
      width: 300,
      height: 600,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade800.withAlpha(100),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isActivePlayer ? Colors.yellow : Colors.transparent,
          width: isActivePlayer ? 4.0 : 12.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //
          // Header
          //
          PlayerHeader(name: playerName, score: playerScore),
          const SizedBox(height: 20),

          //
          // Cards in Hand
          //
          Expanded(
            child: buildPlayerHand(context, gameModel, index),
          ),
          const SizedBox(height: 20),

          //
          // CTA
          //
          PlayerZoneCTA(isActivePlayer: isActivePlayer, gameModel: gameModel),
        ],
      ),
    );
  }

  Widget buildPlayerHand(BuildContext context, GameModel gameModel, int index) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
      ),
      itemCount: gameModel.playerHands[index].length,
      itemBuilder: (context, gridIndex) {
        return buildPlayerCardButton(context, gameModel, index, gridIndex);
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
        gameModel.currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
      },
      child:
          isVisible ? PlayingCardWidget(card: card) : const HiddenCardWidget(),
    );
  }
}
