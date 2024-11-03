import 'dart:async';

import 'package:cards/models/backend_model.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// The initial screen presented to the user, allowing them to join or start a game.
///
/// Users can enter their name and a room name. If the room exists, they can
/// join it; otherwise, a new room is created. The screen displays a list of
/// players currently in the room.  Once at least two players have joined, the
/// game can be started.  The screen also provides a brief explanation of the
/// game's rules.
class StartScreen extends StatefulWidget {
  /// Creates the Start Screen widget.
  const StartScreen({super.key});

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  /// Subscription to the Firebase Realtime Database.
  StreamSubscription? _streamSubscription;

  /// Controller for the room name text field.
  final TextEditingController _controllerRoom = TextEditingController(
    text: 'KIWI', // Default room name
  );

  String get roomId => _controllerRoom.text.trim().toUpperCase();

  /// Placeholder for room name error text.  Currently unused.
  final String _errorTextRoom = '';

  /// Controller for the player name text field.
  final TextEditingController _controllerName = TextEditingController();

  /// Placeholder for player name error text. Currently unused.
  final String _errorTextName = '';

  /// List of player names currently in the room.
  Set<String> _playerNames = {};

  /// Returns the trimmed player name entered by the user.
  String get _playerName => _controllerName.text.trim();
  bool waitingOnFirstBackendData = true;

  @override
  void initState() {
    super.initState();
    prepareBackEndForRoom(roomId);
  }

  @override
  void dispose() {
    // Cancel the Firebase subscription to prevent leaks.
    _streamSubscription?.cancel();
    super.dispose();
  }

  void prepareBackEndForRoom(final String roomId) {
    waitingOnFirstBackendData = true;

    _streamSubscription?.cancel();

    // First pull
    useFirebase().then((_) async {
      final invitees = await getPlayersInRoom(roomId);
      setState(() {
        _playerNames = Set.from(invitees);
        waitingOnFirstBackendData = false;
      });
    });

    // Listen for updates
    useFirebase().then((_) {
      _streamSubscription = onBackendInviteesUpdated(roomId, (invitees) {
        setState(() {
          _playerNames = Set.from(invitees);
          waitingOnFirstBackendData = false;
        });
      });
    });
  }

  Widget loading() {
    return SizedBox(
      width: 400,
      height: 400,
      child: Center(
        child: const CupertinoActivityIndicator(
          radius: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: '9 Cards Golf',
      child: SingleChildScrollView(
        child: Center(
          child: waitingOnFirstBackendData
              ? loading()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        gameInstructions(),
                        const SizedBox(height: 40),
                        editBox(
                          'Room',
                          _controllerRoom,
                          () {
                            _controllerRoom.text =
                                _controllerRoom.text.toUpperCase();
                            prepareBackEndForRoom(roomId);
                          },
                          _errorTextRoom,
                        ),
                        const SizedBox(height: 20),
                        editBox(
                          'Name',
                          _controllerName,
                          () {
                            _controllerName.text =
                                _controllerName.text.toUpperCase();
                            joinGame(_controllerName.text);
                          },
                          _errorTextName,
                        ),
                        const SizedBox(height: 20),
                        actionButton(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: PlayersInRoomWidget(
                            name: _playerName,
                            playerNames: _playerNames.toList(),
                            onRemovePlayer: removePlayer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget gameInstructions() {
    return SizedBox(
      height: 200,
      child: Markdown(
        selectable: true,
        data: '### Game Rules'
            '\n- Aim for the lowest possible score.'
            '\n- Choose a card from either the Deck or Discard pile.'
            '\n- Swap the chosen card with a card in your 3x3 grid, or discard it and flip over one of your face-down cards.'
            '\n- Three cards of the same rank in a row or column score zero.'
            '\n- The first player to reveal all nine cards challenges others, claiming the lowest score.'
            '\n- If someone else has an equal or lower score, the challenger doubles their points!'
            '\n- Players are eliminated after busting 100 points.'
            '\n'
            '\n'
            'Learn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))',
        onTapLink: (text, href, title) async {
          if (href != null) {
            await launchUrlString(
              href,
            ); // Use launchUrlString directly with the href string
          }
        },
      ),
    );
  }

  /// Widget for creating labeled text input fields.
  Widget editBox(
    final String label,
    final TextEditingController controller,
    final Function() onSubmitted,
    final String errorStatus,
  ) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 19, 67, 22),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Type your $label here',
                hintStyle: TextStyle(color: Colors.black.withAlpha(100)),
                errorText: errorStatus.isEmpty ? null : errorStatus,
              ),
              onEditingComplete: onSubmitted,
              onSubmitted: (_) {
                onSubmitted();
              },
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds the a player or players to a room.
  ///
  /// Takes a comma-separated string of names, converts them to uppercase,
  /// trims whitespace, and adds them to the list of players.  If the list
  /// already contains the player's name, it does nothing.  Updates the backend
  /// with the new player list. After successfully adding the player, the player
  /// name input field is updated to reflect only the first entered name.
  void joinGame(final String nameOrNamesToAdd) {
    if (nameOrNamesToAdd.trim().isNotEmpty) {
      final names = nameOrNamesToAdd.toUpperCase().split(',');
      for (final name in names) {
        _playerNames.add(name.trim());
      }

      setPlayersInRoom(roomId, _playerNames);
      _controllerName.text = names.first;
    }
  }

  /// Removes a player from the game.
  void removePlayer(final String nameToRemove) {
    // remove the name of player from the list of players
    _playerNames.remove(nameToRemove);

    // push to back end
    setPlayersInRoom(roomId, _playerNames);
  }

  /// Starts the game and navigates to the game screen.
  void startGame(BuildContext context) {
    final newGame = GameModel(
      names: _playerNames.toList(),
      gameRoomId: roomId,
      isNewGame: true,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameModel: newGame),
      ),
    );
  }

  /// Widget for the "Join Game" or "Start Game" button.
  Widget actionButton() {
    if (_playerName.isEmpty) {
      return const Text('Please enter your name above ⬆');
    }
    bool isPartOfTheList = _playerNames.contains(_playerName.toUpperCase());

    String label = isPartOfTheList
        ? (_playerNames.length > 1
            ? 'Start Game'
            : 'Waiting for players to join')
        : 'Join Game';
    return ElevatedButton(
      onPressed: () {
        if (isPartOfTheList) {
          if (_playerNames.length > 1) {
            startGame(context);
          }
        } else {
          joinGame(_playerName);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
