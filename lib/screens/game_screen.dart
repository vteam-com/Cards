import 'dart:async';
import 'dart:convert';

import 'package:cards/models/game_model.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/player_zone_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameModel});

  final GameModel gameModel;
  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late StreamSubscription _streamSubscription;
  late ScrollController _scrollController;
  List<GlobalKey> _playerKeys = [];
  bool phoneLayout = false;

  @override
  void initState() {
    super.initState();
    initFirebaseListen();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActivePlayer(widget.gameModel);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Screen(
      title: '',
      backButton: true,
      child: _adaptiveLayout(
        context,
        widget.gameModel,
        width,
      ),
    );
  }

  void initFirebaseListen() {
    _streamSubscription = FirebaseDatabase.instance
        .ref('rooms/room1/state')
        .onValue
        .listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Object? data = snapshot.value;
      if (data != null) {
        // Convert the data to a Map<String, dynamic>
        String jsonData = jsonEncode(data);
        Map<String, dynamic> mapData = jsonDecode(jsonData);
        widget.gameModel.fromJson(mapData);
        setState(() {
          _playerKeys = List.generate(
            widget.gameModel.numPlayers,
            (index) => GlobalKey(),
          );

          // update UI
        });
      }
    });
  }

  /// Adapts the layout based on the screen width.
  ///
  /// Determines whether to use the desktop/tablet layout or the phone layout
  /// based on the provided `width`.  Sets the `phoneLayout` flag accordingly,
  /// which is used to adjust scrolling behavior.
  ///
  /// Args:
  ///   context: The BuildContext for the widget.
  ///   gameModel: The GameModel providing game state data.
  ///   width: The width of the screen.
  ///
  /// Returns:
  ///   The appropriate layout widget based on the screen width.
  Widget _adaptiveLayout(
    BuildContext context,
    GameModel gameModel,
    final double width,
  ) {
    // DESKTOP or TABLET
    if (width >= ResponsiveBreakpoints.desktop ||
        width >= ResponsiveBreakpoints.tablet) {
      // Use tablet breakpoint here
      phoneLayout = false;
      return _layoutForDesktop(context, gameModel);
    }

    // PHONE
    phoneLayout = true;
    return _layoutForPhone(context, gameModel);
  }

  void _scrollToActivePlayer(final GameModel gameModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int playerIndex = gameModel.playerIdPlaying;
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

  /// Builds the layout for desktop-sized screens.
  ///
  /// This layout arranges the player zones in a horizontally wrapping layout
  /// within a scrollable area. A banner is displayed at the top, providing
  /// game information.
  ///
  /// Args:
  ///   context: The BuildContext for the widget.
  ///   gameModel: The GameModel providing game state data.
  ///
  /// Returns:
  ///   A Column widget containing the banner and scrollable player zones.
  Widget _layoutForDesktop(BuildContext context, GameModel gameModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _banner(gameModel), // Display the game banner
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
              child: SingleChildScrollView(
                controller: _scrollController, // Controller for scrolling
                child: _buildPlayersWrapLayout(
                  context,
                  gameModel,
                ), // Player zones in a wrap layout
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the layout for phone-sized screens.
  ///
  /// This layout arranges the player zones vertically within a scrollable column.
  /// A dense banner is displayed at the top, providing game information.
  ///
  /// Args:
  ///   context: The BuildContext for the widget.
  ///   gameModel: The GameModel providing game state data.
  ///
  /// Returns:
  ///   A Column widget containing the banner and scrollable player zones.
  Widget _layoutForPhone(BuildContext context, GameModel gameModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _banner(gameModel, dense: true), // Display a compact banner
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController, // Controller for scrolling
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(gameModel.numPlayers, (index) {
                return Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ), // Add padding around each player zone
                  child: PlayerZoneWidget(
                    key: _playerKeys[
                        index], // Key for identifying the player zone
                    gameModel: gameModel, // Game state data
                    indexOfPlayer: index, // Index of the player
                    smallDevice: true, // Indicate that this is a small device
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a horizontally wrapping layout for displaying player zones.
  ///
  /// This method generates a list of [PlayerZoneWidget] widgets, one for each player
  /// in the game. These widgets are then arranged in a [Wrap] layout, allowing
  /// them to wrap onto multiple rows if necessary, depending on the available
  /// screen width.  Spacing is added between the player zones for visual clarity.
  ///
  /// Args:
  ///   context: The BuildContext for the widget.
  ///   gameModel: The GameModel providing game state data.
  ///
  /// Returns:
  ///   A Wrap widget containing the player zones.
  Widget _buildPlayersWrapLayout(BuildContext context, GameModel gameModel) {
    return Wrap(
      spacing: 40.0, // Horizontal spacing between player zones
      runSpacing: 40.0, // Vertical spacing between rows of player zones
      children: List.generate(gameModel.numPlayers, (index) {
        return PlayerZoneWidget(
          key: _playerKeys[index], // Key for identifying the player zone
          gameModel: gameModel, // Game state data
          indexOfPlayer: index, // Index of the player
          smallDevice: false, // Indicate that this is not a small device
        );
      }),
    );
  }

  /// Displays a banner message indicating the current player's turn and game status.
  ///
  /// The banner highlights the active player's name and, if applicable, the name of
  /// the player they need to beat in the final round.  The game room ID is also displayed.
  ///
  /// The `dense` parameter controls the font size and padding, allowing for a more compact
  /// banner on smaller screens.
  Widget _banner(
    GameModel gameModel, {
    bool dense = false,
  }) {
    /// Name of the currently active player.
    String playersName = gameModel.getPlayerName(gameModel.playerIdPlaying);

    /// Name of the player the active player needs to beat in the final round (if applicable).
    String playerAttackerName =
        gameModel.getPlayerName(gameModel.playerIdAttacking);

    /// Base text for the banner message.
    String inputText =
        'In ${gameModel.gameRoomId} room: It\'s your turn $playersName. Room: ';

    /// Modifies the banner text if it's the final turn, indicating who the active player
    /// needs to beat.
    if (gameModel.isFinalTurn) {
      inputText =
          'Final Round. $inputText. You have to beat $playerAttackerName';
    }

    /// Keywords to highlight in the banner text.
    List<String> keywords = [playersName, playerAttackerName];

    /// Returns the styled banner widget.
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

/// Generates a list of TextSpans to style. Keywords are bolded.
///
/// Iterates through the keywords and applies bold styling to each occurrence within
/// the input text.  The remaining text maintains the default style.
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
