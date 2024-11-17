import 'package:flutter/material.dart';

class RoomsWidget extends StatelessWidget {
  const RoomsWidget({
    super.key,
    required this.roomId,
    required this.rooms,
    required this.onSelected,
    required this.onRemoveRoom,
  });

  final String roomId;
  final List<String> rooms;
  final Function(String) onSelected;
  final Function(String)? onRemoveRoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          String nameToDisplay = rooms[index];
          return ListTile(
            title: TextButton(
              onPressed: () => onSelected(rooms[index]),
              child: Text(
                nameToDisplay,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            leading: SizedBox(
              width: 40,
              child: nameToDisplay == roomId ? Icon(Icons.check) : null,
            ),
            trailing: onRemoveRoom == null
                ? null
                : IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red.shade300),
                    onPressed: () => onRemoveRoom!(rooms[index]),
                  ),
          );
        },
      ),
    );
  }
}
