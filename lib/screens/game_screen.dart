import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/player_zone.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late ScrollController _scrollController;
  List<GlobalKey> _playerKeys = [];
  bool phoneLayout = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    // Initialize keys based on number of players
    final gameModel = Provider.of<GameModel>(context);
    _playerKeys = List.generate(gameModel.numPlayers, (index) => GlobalKey());
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (final BuildContext context, final GameModel gameModel, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToActivePlayer(gameModel);
        });

        final double width = MediaQuery.of(context).size.width;
        return Screen(
          title: '',
          backButton: true,
          child: adaptiveLayout(
            context,
            gameModel,
            width,
          ),
        );
      },
    );
  }

  Widget adaptiveLayout(
    BuildContext context,
    GameModel gameModel,
    final double width,
  ) {
    // DESKTOP or TABLET
    if (width >= ResponsiveBreakpoints.desktop ||
        width >= ResponsiveBreakpoints.phone) {
      phoneLayout = false;
      return layoutForDesktop(context, gameModel);
    }

    // PHONE
    phoneLayout = true;
    return layoutForPhone(context, gameModel);
  }

  void _scrollToActivePlayer(final GameModel gameModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int playerIndex = gameModel.currentPlayerIndex;
      if (playerIndex < _playerKeys.length) {
        final RenderBox? containerBox =
            context.findRenderObject() as RenderBox?;
        final RenderBox? playerBox = _playerKeys[playerIndex]
            .currentContext
            ?.findRenderObject() as RenderBox?;

        if (containerBox != null && playerBox != null) {
          final double containerOffset =
              containerBox.localToGlobal(Offset.zero).dy;
          final double playerOffset =
              playerBox.localToGlobal(Offset.zero).dy - containerOffset;
          final double offset = _scrollController.offset + playerOffset;

          // Calculate maximum scroll extent
          final double maxScrollExtent =
              _scrollController.position.maxScrollExtent;

          // Ensure offset is within bounds
          final double targetOffset = (offset - (phoneLayout ? 50 : 100)).clamp(
            0.0,
            maxScrollExtent,
          );

          // Animate to the adjusted offset
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Widget layoutForDesktop(BuildContext context, GameModel gameModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          banner(gameModel),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
              child: SingleChildScrollView(
                controller: _scrollController,
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
        banner(gameModel, dense: true),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(gameModel.numPlayers, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlayerZone(
                    key: _playerKeys[index],
                    gameModel: gameModel,
                    index: index,
                    smallDevice: true,
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
          key: _playerKeys[index],
          gameModel: gameModel,
          index: index,
          smallDevice: false,
        );
      }),
    );
  }

  Widget banner(
    GameModel gameModel, {
    bool dense = false,
  }) {
    String playersName = gameModel.activePlayerName;
    String inputText = 'It\'s your turn $playersName.';
    String playerAttackerName =
        gameModel.getPlayerName(gameModel.playerIndexOfAttacker);

    if (gameModel.finalTurn) {
      inputText =
          'Final Round. $inputText. You have to beat $playerAttackerName';
    }

    List<String> keywords = [playersName, playerAttackerName];

    List<TextSpan> generateStyledText(String text, List<String> keywords) {
      List<TextSpan> spans = [];
      int start = 0;
      final textLower = text.toLowerCase();

      for (final keyword in keywords) {
        final keywordLower = keyword.toLowerCase();
        int index = textLower.indexOf(keywordLower, start);

        while (index >= 0) {
          if (index > start) {
            // Add normal text before the keyword
            spans.add(TextSpan(text: text.substring(start, index)));
          }
          // Add the keyword with bold style
          spans.add(
            TextSpan(
              text: text.substring(index, index + keyword.length),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: dense ? 16 : 20,
              ),
            ),
          );
          start = index + keyword.length;
          index = textLower.indexOf(keywordLower, start);
        }
      }

      // Add remaining text
      if (start < text.length) {
        spans.add(TextSpan(text: text.substring(start)));
      }

      return spans;
    }

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
          children: generateStyledText(inputText, keywords),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
