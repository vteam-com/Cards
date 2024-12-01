import 'package:cards/models/game_model.dart';
import 'package:cards/models/golf_french_suit_deck_model.dart';
import 'package:cards/models/golf_player_model.dart';

class GolfGameModel extends GameModel {
  /// Creates a new Game game model.
  ///
  /// [gameRoomId] is the ID of the room this game is in.
  /// [names] is the list of player names.
  /// [isNewGame] indicates whether this is a new game or joining an existing one.
  GolfGameModel({
    required super.gameRoomId,
    required super.loginUserName,
    required super.names,
    super.isNewGame,
  }) : super(
          cardsToDeal: 9,
          deck:
              GolfFrenchSuitDeckModel(numberOfDecks: ((names.length + 1) ~/ 2)),
        );

  @override
  DeckModel loadDeck(Map<String, dynamic> json) {
    return GolfFrenchSuitDeckModel.fromJson(json);
  }

  @override
  PlayerModel loadPlayer(Map<String, dynamic> json) {
    return PlayerModel.fromJson(json);
  }

  @override
  void addPlayer(String name) {
    players.add(GolfPlayerModel(name: name));
  }
}
