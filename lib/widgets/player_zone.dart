import 'package:cards/game_model.dart';
import 'package:cards/widgets/player_header.dart';
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PlayerHeader(name: playerName, score: playerScore),
          const SizedBox(height: 20),
          buildPlayerHand(context, gameModel, index),
          const SizedBox(height: 20),
          buildPlayerAction(isActivePlayer, gameModel),
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

  Widget buildPlayerAction(bool isActivePlayer, final GameModel gameModel) {
    if (isActivePlayer && gameModel.cardPickedUpFromDeckOrDiscarded != null) {
      bool showActionButton = gameModel.currentPlayerStates ==
          CurrentPlayerStates.takeKeepOrDiscard;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (gameModel.currentPlayerStates == CurrentPlayerStates.flipAndSwap)
            buildMiniInstructions(
              isActivePlayer,
              getInstructionToPlayer(gameModel.currentPlayerStates),
            ),
          if (showActionButton)
            ElevatedButton(
              child: const Text('Keep'),
              onPressed: () {
                // swap the card in the player's hand
                gameModel.currentPlayerStates = CurrentPlayerStates.flipAndSwap;
              },
            ),
          SizedBox(
            width: 66,
            height: 100,
            child: PlayingCardWidget(
              card: gameModel.cardPickedUpFromDeckOrDiscarded!,
            ),
          ),
          if (showActionButton)
            ElevatedButton(
              child: const Text('Discard'),
              onPressed: () {
                // return the card to the discard pile
                gameModel.cardsDeckDiscarded
                    .add(gameModel.cardPickedUpFromDeckOrDiscarded!);
                gameModel.cardPickedUpFromDeckOrDiscarded = null;
                gameModel.currentPlayerStates = CurrentPlayerStates.flipOneCard;
              },
            ),
        ],
      );
    }
    return SizedBox(
      height: 100,
      child: buildMiniInstructions(
        isActivePlayer,
        isActivePlayer
            ? getInstructionToPlayer(gameModel.currentPlayerStates)
            : 'Wait for your turn :)',
      ),
    );
  }

  Widget buildMiniInstructions(bool isActivePlayer, String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: isActivePlayer ? 20 : 12,
          color: Colors.white.withAlpha(isActivePlayer ? 255 : 140),
        ),
      ),
    );
  }
}
