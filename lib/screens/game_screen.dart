import 'package:cards/widgets/card_deck.dart';
import 'package:cards/widgets/player_zone.dart';
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
        return PlayerZone(
          gameModel: gameModel,
          index: index,
        );
      }),
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
              cardsInTheDeck: context.watch<GameModel>().cardsDeckPile.length,
              discardedCards: context.watch<GameModel>().cardsDeckDiscarded,
              onDrawCard: () {
                final gameModel = context.read<GameModel>();
                gameModel.drawCard(context, fromDiscardPile: false);
              },
              onDrawDiscardedCard: () {
                final gameModel = context.read<GameModel>();
                gameModel.drawCard(context, fromDiscardPile: true);
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
