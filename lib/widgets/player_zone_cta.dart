import 'package:cards/game_model.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneCTA extends StatelessWidget {
  const PlayerZoneCTA({
    super.key,
    required this.isActivePlayer,
    required this.gameModel,
  });
  final bool isActivePlayer;
  final GameModel gameModel;

  @override
  Widget build(BuildContext context) {
    if (isActivePlayer) {
      return buildActivePlayerContent();
    }
    return buildWaitingForTurnContent();
  }

  Widget buildActivePlayerContent() {
    switch (gameModel.currentPlayerStates) {
      case CurrentPlayerStates.keepOrDiscard:
        return buildTakeKeepOrDiscardContent();
      case CurrentPlayerStates.flipAndSwap:
        return buildFlipAndSwapContent();
      // Define additional cases for other states as needed
      case CurrentPlayerStates.pickCardFromDeck:
      default:
        return isActivePlayer
            ? buildMiniInstructions(
                isActivePlayer,
                getInstructionToPlayer(gameModel.currentPlayerStates),
              )
            : buildWaitingForTurnContent();
    }
  }

  Widget buildTakeKeepOrDiscardContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          child: const Text(
            'Keep',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          onPressed: () {
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
        ElevatedButton(
          child: const Text(
            'Discard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            gameModel.cardsDeckDiscarded
                .add(gameModel.cardPickedUpFromDeckOrDiscarded!);
            gameModel.cardPickedUpFromDeckOrDiscarded = null;
            gameModel.currentPlayerStates = CurrentPlayerStates.flipOneCard;
          },
        ),
      ],
    );
  }

  Widget buildFlipAndSwapContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildMiniInstructions(
          isActivePlayer,
          getInstructionToPlayer(gameModel.currentPlayerStates),
        ),
        SizedBox(
          width: 66,
          height: 100,
          child: PlayingCardWidget(
            card: gameModel.cardPickedUpFromDeckOrDiscarded!,
          ),
        ),
      ],
    );
  }

  Widget buildWaitingForTurnContent() {
    return buildMiniInstructions(
      isActivePlayer,
      'Wait for your turn :)',
    );
  }
}

Widget buildMiniInstructions(bool isActivePlayer, String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: isActivePlayer ? 20 : 14,
      color: Colors.white.withAlpha(isActivePlayer ? 255 : 140),
    ),
  );
}
