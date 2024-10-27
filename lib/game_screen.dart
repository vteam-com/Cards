import 'package:cards/widgets/card_deck.dart';
import 'package:cards/widgets/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';
import 'playing_card_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('9-Card Golf Game'),
      ),
      body: Consumer<GameModel>(
        builder: (context, GameModel gameModel, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  Expanded(child: _buildPlayers(gameModel)),
                  const SizedBox(height: 20),
                  _buildInstructionText(gameModel.activePlayerName),
                  const SizedBox(height: 20),
                  DeckOfCards(
                    cardsRemaining: context.watch<GameModel>().deck.length,
                    topOpenCard: context.watch<GameModel>().openCards.isNotEmpty
                        ? context.watch<GameModel>().openCards.last
                        : null,
                    onDrawCard: () {
                      context.read<GameModel>().drawCard();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayers(final GameModel gameModel) {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: List.generate(
        gameModel.numPlayers,
        (int index) {
          String playerName = gameModel.playerNames[index];
          int playerScore = gameModel.calculatePlayerScore(index);
          bool isActivePlayer = gameModel.activePlayerIndex == index;
          return Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade800.withAlpha(100),
              borderRadius: BorderRadius.circular(20.0),
              border: isActivePlayer
                  ? Border.all(
                      color: Colors.yellow,
                      width: 4.0,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Player(
                  name: playerName,
                  score: playerScore,
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: gameModel.playerHands[index].length,
                  itemBuilder: (context, gridIndex) {
                    bool isVisible = gameModel.cardVisibility[index][gridIndex];
                    var card = gameModel.playerHands[index][gridIndex];
                    return GestureDetector(
                      onTap: () {
                        gameModel.toggleCardVisibility(
                          index,
                          gridIndex,
                        );
                        gameModel.saveGameState();
                      },
                      child: isVisible
                          ? PlayingCardWidget(card: card)
                          : const HiddenCardWidget(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Define a function to build the instructions for the active player
  Widget _buildInstructionText(final String playersName) {
    String instructionText =
        'It\'s your turn $playersName! Choose to either pick the open deck card or tap on the top of the hidden deck.';

    // Instruction Text Area
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black54),
      ),
      child: Text(
        instructionText,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
