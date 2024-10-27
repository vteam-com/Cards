import 'package:cards/widgets/card_deck.dart';
import 'package:cards/widgets/player_header.dart';
import 'package:cards/widgets/playing_card_widget.dart';
import 'package:cards/widgets/screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (final BuildContext context, final GameModel gameModel, _) {
        return Screen(
          title: '9-Card Golf Game',
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
                    child: SingleChildScrollView(
                      child: buildPlayers(context, gameModel),
                    ),
                  ),
                ),
                _buildCroupier(context, gameModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPlayers(BuildContext context, GameModel gameModel) {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: List.generate(gameModel.numPlayers, (index) {
        return buildPlayerIsland(context, gameModel, index);
      }),
    );
  }

  Widget buildPlayerIsland(
    BuildContext context,
    GameModel gameModel,
    int index,
  ) {
    final playerName = gameModel.playerNames[index];
    final playerScore = gameModel.calculatePlayerScore(index);
    final isActivePlayer = gameModel.currentPlayerIndex == index;
    return Container(
      width: 300,
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
                setState(() {
                  // swap the card in the player's hand
                  gameModel.currentPlayerStates =
                      CurrentPlayerStates.flipAndSwap;
                });
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
                setState(() {
                  // return the card to the discard pile
                  gameModel.discardedCards
                      .add(gameModel.cardPickedUpFromDeckOrDiscarded!);
                  gameModel.cardPickedUpFromDeckOrDiscarded = null;
                  gameModel.currentPlayerStates =
                      CurrentPlayerStates.flipOneCard;
                });
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

  Widget buildPlayerHand(BuildContext context, GameModel gameModel, int index) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: gameModel.playerHands[index].length,
      itemBuilder: (context, gridIndex) {
        return _buildPlayerCardButton(context, gameModel, index, gridIndex);
      },
    );
  }

  Widget _buildPlayerCardButton(
    BuildContext context,
    GameModel gameModel,
    int playerIndex,
    int gridIndex,
  ) {
    final isVisible = gameModel.cardVisibility[playerIndex][gridIndex];
    final card = gameModel.playerHands[playerIndex][gridIndex];

    return GestureDetector(
      onTap: () {
        gameModel.revealCard(context, playerIndex, gridIndex);
        gameModel.currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
      },
      child:
          isVisible ? PlayingCardWidget(card: card) : const HiddenCardWidget(),
    );
  }

  Widget _buildCroupier(BuildContext context, GameModel gameModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          _buildInstructionText(gameModel.activePlayerName),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 200,
            child: DeckOfCards(
              cardsInTheDeck: context.watch<GameModel>().cardsInTheDeck.length,
              discardedCards: context.watch<GameModel>().discardedCards,
              onDrawCard: () {
                final gameModel = context.read<GameModel>();
                gameModel.playerDrawsFromDeck(context);
              },
              onDrawDiscardedCard: () {
                final gameModel = context.read<GameModel>();
                gameModel.playerDrawsFromDiscardedDeck(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(String playersName) {
    final instructionText =
        'It\'s your turn $playersName, pick a card from the deck or discarded pile.';

    final parts = instructionText.split(playersName);
    final beforeName = parts[0];
    final afterName = parts[1];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black54),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 20, color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: beforeName),
            TextSpan(
              text: playersName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            TextSpan(text: afterName),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
