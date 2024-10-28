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
          title: '',
          backButton: true,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInstructionText(gameModel.activePlayerName),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
                    child: SingleChildScrollView(
                      child: buildPlayers(context, gameModel),
                    ),
                  ),
                ),
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

  Widget _buildInstructionText(String playersName) {
    final instructionText = 'It\'s your turn $playersName.';

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
