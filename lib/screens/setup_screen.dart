import 'dart:async';

import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/players_in_room_widget.dart';
import 'package:cards/widgets/text_url_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  PlayerSetupScreenState createState() => PlayerSetupScreenState();
}

class PlayerSetupScreenState extends State<PlayerSetupScreen> {
  late StreamSubscription _streamSubscription;
  String joiningAs = '';

  final TextEditingController _controllerRoom = TextEditingController(
    text: 'Banana', // Default player names
  );
  final String _errorTextRoom = '';

  final TextEditingController _controllerName = TextEditingController(
    text: 'PowerRanger', // Default player names
  );
  final String _errorTextName = '';

  List<String> _playerNames = [];

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        FirebaseDatabase.instance.ref().onValue.listen((event) {
      final DataSnapshot snapshot = event.snapshot;
      final Object? data = snapshot.value;
      if (data != null) {
        if (data is Map<Object?, Object?>) {
          final room = data['rooms'] as Map<Object?, Object?>;
          final room1 = room['room1'] as Map<Object?, Object?>;
          final players = room1['players'] as List<Object?>;

          setState(() {
            _playerNames = [];
            for (final Object? playerName in players) {
              if (playerName != null) {
                var name = playerName as String;
                _playerNames.add(name);
              }
            }
          });
        } else if (data is List<dynamic>) {
          // Handle List data
        } else if (data is String) {
          // Handle String data
        } else if (data is num) {
          // Handle Number data
        } else if (data is bool) {
          // Handle Boolean data
        } else {
          // Handle null or other unexpected types
        }
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      backButton: false,
      title: '9 Cards Golf',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'Players swap cards in their grid to score as low as possible. Lining up three of the same rank in a row or column counts as zero. Anyone can end a round by “closing,” but if someone scores lower, the closer’s points double!\n',
                  style: TextStyle(
                    color: Colors.green.shade100,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const TextWithLinkWidget(
                  text: 'Learn more',
                  linkText: 'Wikipedia',
                  url: 'https://en.wikipedia.org/wiki/Golf_(card_game)',
                ),
                const Spacer(),
                editBox('Room', _controllerRoom, _errorTextRoom),
                const SizedBox(height: 20),
                if (joiningAs.isEmpty)
                  editBox('Name', _controllerName, _errorTextName),
                const SizedBox(height: 40),
                if (joiningAs.isEmpty)
                  Material(
                    elevation: 125,
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    child: TextButton(
                      onPressed: () {
                        joinGame(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Join Game',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 400,
                  height: 300,
                  child: PlayersInRoomWidget(
                    playerNames: _playerNames,
                    onRemovePlayer: (String nameToRemove) {
                      removePlayer(nameToRemove);
                    },
                  ),
                ),
                const SizedBox(height: 40),
                if (_playerNames.length > 1)
                  Material(
                    elevation: 125,
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    child: TextButton(
                      onPressed: () {
                        startGame(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Start Game',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: label,
                errorText: errorStatus.isEmpty ? null : errorStatus,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void joinGame(BuildContext context) {
    String nameOfPersonJoining = _controllerName.text.trim();

    _playerNames.add(nameOfPersonJoining);
    pushPlayersNamesToFirebase();
    joiningAs = nameOfPersonJoining;
  }

  void pushPlayersNamesToFirebase() {
    final refPlayers =
        FirebaseDatabase.instance.ref().child('rooms/room1/players');
    refPlayers.set(_playerNames);
  }

  void removePlayer(final String nameToRemove) {
    _playerNames = _playerNames.where((name) => name != nameToRemove).toList();
    pushPlayersNamesToFirebase();
  }

  void startGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => GameModel(
            names: _playerNames,
            gameRoomId: _controllerRoom.text.trim(),
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }

  List<String> parsePlayerNames(String input) {
    if (input.isEmpty) {
      return [];
    }

    // Split by spaces, commas, or semicolons and remove empty entries
    List<String> names = input
        .split(RegExp(r'[ ,;]+'))
        .where((name) => name.isNotEmpty)
        .toList();

    return names;
  }
}
