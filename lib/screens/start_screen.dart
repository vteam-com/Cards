import 'dart:async';

import 'package:cards/models/backend_model.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:firebase_database/firebase_database.dart';
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
  late StreamSubscription _streamSubscription;

  /// Controller for the room name text field.
  final TextEditingController _controllerRoom = TextEditingController(
    text: 'KIWI', // Default room name
  );

  /// Placeholder for room name error text.  Currently unused.
  final String _errorTextRoom = '';

  /// Controller for the player name text field.
  final TextEditingController _controllerName = TextEditingController();

  /// Placeholder for player name error text. Currently unused.
  final String _errorTextName = '';

  /// List of player names currently in the room.
  List<String> _playerNames = [];

  /// Returns the trimmed player name entered by the user.
  String get playerName => _controllerName.text.trim();

  @override
  void initState() {
    super.initState();

    // Set up the Firebase listener after ensuring Firebase is initialized.
    useFirebase().then((_) {
      _streamSubscription =
          FirebaseDatabase.instance.ref().onValue.listen((event) {
        final DataSnapshot snapshot = event.snapshot;
        final Object? data = snapshot.value;

        // Safely access and update the player list from the Firebase snapshot.
        if (data != null && data is Map) {
          final room = data['rooms'] as Map?;
          if (room != null) {
            final room1 = room['room1'] as Map?;
            if (room1 != null) {
              final players = room1['players'] as List?;
              if (players != null) {
                setState(() {
                  _playerNames = players.cast<String>().toList();
                });
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancel the Firebase subscription to prevent leaks.
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      backButton: false,
      title: '9 Cards Golf',
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  gameInstructions(),
                  const SizedBox(height: 40),
                  editBox('Room', _controllerRoom, _errorTextRoom),
                  const SizedBox(height: 20),
                  editBox('Name', _controllerName, _errorTextName),
                  const SizedBox(height: 40),
                  actionButton(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 400,
                    height: 300,
                    child: PlayersInRoomWidget(
                      name: playerName,
                      playerNames: _playerNames,
                      onRemovePlayer: removePlayer,
                    ),
                  ),
                  const SizedBox(height: 40),
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
        data: '## Players swap cards in their grid to score as low as possible.'
            '\n- Lining up three of the same rank in a row or column counts as zero.'
            '\n- Anyone can end a round by “closing,” but if someone scores lower, the closer’s points are doubled!'
            '\n'
            '\n'
            'Learn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))',
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrlString(
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
    final String errorStatus,
  ) {
    return Container(
      width: 400,
      height: 100,
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
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds the current player to the game.
  void joinGame(BuildContext context) {
    String nameOfPersonJoining = playerName.toUpperCase();
    _playerNames.add(nameOfPersonJoining);
    pushPlayersNamesToFirebase();
  }

  /// Updates the player list in Firebase.
  void pushPlayersNamesToFirebase() {
    useFirebase().then((_) {
      FirebaseDatabase.instance
          .ref()
          .child('rooms/room1/players')
          .set(_playerNames);
    });
  }

  /// Removes a player from the game.
  void removePlayer(final String nameToRemove) {
    _playerNames = _playerNames.where((name) => name != nameToRemove).toList();
    pushPlayersNamesToFirebase();
  }

  /// Starts the game and navigates to the game screen.
  void startGame(BuildContext context) {
    final newGame = GameModel(
      names: _playerNames,
      gameRoomId: _controllerRoom.text.trim().toUpperCase(),
      isNewGame: true,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameModel: newGame),
      ),
    );
  }

  /// Widget for the "Join Game" or "Start Game" button.
  Widget actionButton() {
    if (playerName.isEmpty) {
      return const Text('Please enter your name above ⬆');
    }
    bool isPartOfTheList = _playerNames.contains(playerName.toUpperCase());

    String label = isPartOfTheList
        ? (_playerNames.length > 1 ? 'Start Game' : 'Waiting for players')
        : 'Join Game';
    return ElevatedButton(
      onPressed: () {
        if (isPartOfTheList) {
          if (_playerNames.length > 1) {
            startGame(context);
          }
        } else {
          joinGame(context);
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
