import 'dart:async';
import 'dart:convert';

import 'package:cards/models/game_model.dart';
import 'package:cards/models/game_over_dialog.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/player_zone_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Widget for the main game screen.
///
/// Displays the game board and player information based on the [GameModel]
/// provided.  Adapts the layout dynamically to accommodate different screen
/// sizes, using a wrapping layout for larger screens and a vertical column for
/// smaller screens.  Manages scrolling to keep the active player visible.
///
/// Requires a [GameModel] to be passed in during construction.
class GameScreen extends StatefulWidget {
  /// Creates a new GameScreen widget.
  ///
  /// [gameModel]: The game model providing the game state and player data.
  const GameScreen({super.key, required this.gameModel});

  /// The game model containing the game state and player data.
  final GameModel gameModel;

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  /// Stream subscription for listening to changes in the Firebase database.
  late StreamSubscription _streamSubscription;

  /// Scroll controller for managing the scrolling behavior of the player list.
  late ScrollController _scrollController;

  /// List of GlobalKeys for each player widget, used for scrolling.
  List<GlobalKey> _playerKeys = [];

  /// Flag indicating whether the layout is for a phone-sized screen.
  bool phoneLayout = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseListener();
    _scrollController = ScrollController();

    /// Scroll to the active player after the layout is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActivePlayer();
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
      rightText:
          widget.gameModel.getPlayerName(widget.gameModel.playerIdPlaying),
      backButton: false,
      onRefresh: () {},
      child: _adaptiveLayout(width),
    );
  }

  /// Initializes the Firebase listener for game state updates.
  void _initializeFirebaseListener() {
    _streamSubscription = FirebaseDatabase.instance
        .ref('rooms/${widget.gameModel.gameRoomId}/')
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
          if (widget.gameModel.gameState == GameStates.gameOver) {
            showGameOverDialog(
              context,
              widget.gameModel.players,
              widget.gameModel.initializeGame,
            );
          }
        });
      }
    });
  }

  /// Adapts the layout based on the screen width.
  ///
  /// Uses [ResponsiveBreakpoints] to determine the appropriate layout.
  /// Sets the [phoneLayout flag for adjusting scrolling behavior.
  ///
  /// Args:
  ///   width: The width of the screen.
  ///
  /// Returns:
  ///   The appropriate layout widget.
  Widget _adaptiveLayout(final double width) {
    // DESKTOP or TABLET
    if (width >= ResponsiveBreakpoints.desktop ||
        width >= ResponsiveBreakpoints.tablet) {
      phoneLayout = false;
      return _layoutForDesktop();
    }

    // PHONE
    phoneLayout = true;
    return _layoutForPhone();
  }

  /// Scrolls to the currently active player.
  void _scrollToActivePlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int playerIndex = widget.gameModel.playerIdPlaying;
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

          // Calculate maximum scroll extent and clamp offset
          final double maxScrollExtent =
              _scrollController.position.maxScrollExtent;
          final double targetOffset = (offset - (phoneLayout ? 50 : 100)).clamp(
            0.0,
            maxScrollExtent,
          );

          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  /// Builds the layout for desktop/tablet screens.  Uses a horizontal wrapping layout.
  Widget _layoutForDesktop() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildPlayersWrapLayout(),
        ),
      ),
    );
  }

  /// Builds the layout for phone screens.  Uses a vertical column layout.
  Widget _layoutForPhone() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(widget.gameModel.numPlayers, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlayerZoneWidget(
              key: _playerKeys[index],
              gameModel: widget.gameModel,
              indexOfPlayer: index,
              smallDevice: true,
            ),
          );
        }),
      ),
    );
  }

  /// Builds a horizontally wrapping layout of player zones.
  Widget _buildPlayersWrapLayout() {
    return Wrap(
      spacing: 40.0,
      runSpacing: 40.0,
      children: List.generate(widget.gameModel.numPlayers, (index) {
        return PlayerZoneWidget(
          key: _playerKeys[index],
          gameModel: widget.gameModel,
          indexOfPlayer: index,
          smallDevice: false,
        );
      }),
    );
  }
}
