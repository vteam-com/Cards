import 'package:cards/models/game_model.dart';
import 'package:cards/models/skyjo_deck_model.dart';
import 'package:cards/models/skyjo_player_model.dart';

class SkyjoGameModel extends GameModel {
  /// Creates a new Skyjo game model.
  ///
  /// [gameRoomId] is the ID of the room this game is in.
  /// [names] is the list of player names.
  /// [isNewGame] indicates whether this is a new game or joining an existing one.
  SkyjoGameModel({
    required super.gameRoomId,
    required super.loginUserName,
    required super.names,
    super.isNewGame,
  }) : super(cardsToDeal: 12, deck: SkyjoDeckModel(1));

  @override
  void processEndOfTurn() {
    super.processEndOfTurn();

    var player = players[playerIdPlaying];

    for (int i = 0; i < player.hand.length - 2; i += 3) {
      if (player.hand[i].isRevealed &&
          player.hand[i + 1].isRevealed &&
          player.hand[i + 2].isRevealed &&
          player.areAllTheSameRank(player.hand[i].rank, player.hand[i + 1].rank,
              player.hand[i + 2].rank)) {
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        // We have removed the cards from the hand, reduce the index before the
        // next iteration
        i -= 3;
      }
    }
  }

  @override
  DeckModel loadDeck(Map<String, dynamic> json) {
    return SkyjoDeckModel.fromJson(json);
  }

  @override
  PlayerModel loadPlayer(Map<String, dynamic> json) {
    return SkyjoPlayerModel.fromJson(json);
  }
}
