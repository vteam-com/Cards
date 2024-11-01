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
      title: widget.gameModel.getGameStateAsString(),
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
    return SingleChildScrollView(
      controller: _scrollController, // Controller for scrolling
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(gameModel.numPlayers, (index) {
          return Padding(
            padding: const EdgeInsets.all(
              8.0,
            ), // Add padding around each player zone
            child: PlayerZoneWidget(
              key: _playerKeys[index], // Key for identifying the player zone
              gameModel: gameModel, // Game state data
              indexOfPlayer: index, // Index of the player
              smallDevice: true, // Indicate that this is a small device
            ),
          );
        }),
      ),
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
}
