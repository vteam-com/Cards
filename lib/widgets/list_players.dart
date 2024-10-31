import 'package:flutter/material.dart';

class PlayerListWidget extends StatelessWidget {
  const PlayerListWidget({
    super.key,
    required this.playerNames,
    required this.onRemovePlayer,
  });

  final List<String> playerNames;
  final Function(String) onRemovePlayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${playerNames.length} players waiting')),
      body: Container(
        color: Colors.green.shade800.withAlpha(100),
        child: ListView.builder(
          itemCount: playerNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                playerNames[index],
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => onRemovePlayer(playerNames[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
