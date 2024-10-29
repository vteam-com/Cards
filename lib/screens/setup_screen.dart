import 'package:cards/models/game_model.dart';
import 'package:cards/screens/game_screen.dart';
import 'package:cards/screens/screen.dart';
import 'package:cards/widgets/text_url.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  PlayerSetupScreenState createState() => PlayerSetupScreenState();
}

class PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'John, Paul, George, Ringo', // Default player names
  );
  String _errorText = '';

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
                const TextWithLink(
                  text: 'Learn more',
                  linkText: 'Wikipedia',
                  url: 'https://en.wikipedia.org/wiki/Golf_(card_game)',
                ),
                const Spacer(),
                Text(
                  'Enter players names separated by space, comma, or semicolon',
                  style: TextStyle(color: Colors.green.shade100, fontSize: 20),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 19, 67, 22),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Names',
                      errorText: _errorText.isEmpty ? null : _errorText,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Material(
                  elevation: 125,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  child: TextButton(
                    onPressed: () {
                      _startGame(context);
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

  void _startGame(BuildContext context) {
    String input = _controller.text.trim();
    List<String> playerNames = _parsePlayerNames(input);

    if (playerNames.length > 4) {
      setState(() {
        _errorText = 'Maximum 4 players allowed.';
      });
    } else if (playerNames.isEmpty) {
      setState(() {
        _errorText = 'Please enter at least one player name.';
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => GameModel(names: playerNames),
            child: const GameScreen(),
          ),
        ),
      );
    }
  }

  List<String> _parsePlayerNames(String input) {
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
