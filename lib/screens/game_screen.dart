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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // DESKTOP
              if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
                return layoutForDesktop(context, gameModel);
              }

              // TABLET
              if (constraints.maxWidth >= ResponsiveBreakpoints.phone) {
                return layoutForDesktop(context, gameModel);
              }

              // PHONE
              return layoutForPhone(context, gameModel);
            },
          ),
        );
      },
    );
  }

  Widget layoutForDesktop(BuildContext context, GameModel gameModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInstructionText(gameModel),
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
    );
  }

  Widget layoutForPhone(BuildContext context, GameModel gameModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInstructionText(gameModel, dense: true),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(gameModel.numPlayers, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlayerZone(
                    gameModel: gameModel,
                    index: index,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
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

  Widget _buildInstructionText(GameModel gameModel, {bool dense = false}) {
    String playersName = gameModel.activePlayerName;
    String instructionText = 'It\'s your turn $playersName.';
    String playerAttackerName = '';

    if (gameModel.finalTurn) {
      playerAttackerName =
          gameModel.getPlayerName(gameModel.playerIndexOfAttacker);
      instructionText =
          'Final Round. $instructionText. You have to beat $playerAttackerName';
    }

    final playerNameParts = instructionText.split(playersName);
    final beforePlayerName = playerNameParts[0];
    final afterPlayerNameAndAttacker =
        playerNameParts[1].split(playerAttackerName);

    final afterPlayerName = afterPlayerNameAndAttacker[0];
    final afterAttackerName = afterPlayerNameAndAttacker.length > 1
        ? afterPlayerNameAndAttacker[1]
        : '';

    return Container(
      padding: EdgeInsets.all(dense ? 4 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black54),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: dense ? 12 : 20, color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: beforePlayerName),
            TextSpan(
              text: playersName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: dense ? 16 : 20,
              ),
            ),
            TextSpan(text: afterPlayerName),
            if (playerAttackerName.isNotEmpty) ...[
              TextSpan(
                text: playerAttackerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: dense ? 16 : 20,
                ),
              ),
              TextSpan(text: afterAttackerName),
            ],
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
