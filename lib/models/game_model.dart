import 'package:cards/models/backend_model.dart';
import 'package:cards/models/deck_model.dart';
import 'package:cards/models/game_over_dialog.dart';
import 'package:cards/models/player_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
export 'package:cards/models/deck_model.dart';
export 'package:cards/models/player_model.dart';

class GameModel with ChangeNotifier {
  GameModel({
    required this.gameRoomId,
    required final List<String> names,
    bool newGame = false,
  }) {
    // Initialize players from the list of names
    for (final String name in names) {
      players.add(PlayerModel(name: name));
    }
    if (newGame) {
      initializeGame();
    }
  }

  final String gameRoomId;

  // all things related to game state that needs to be shared/synced across all players
  final List<PlayerModel> players = [];
  DeckModel deck = DeckModel(1);
  int playerIdPlaying = 0;
  int playerIdAttacking = -1;
  bool get isFinalTurn => playerIdAttacking != -1;

  // Private field to hold the state
  GameStates _gameState = GameStates.notStarted;
  // Public getter to access the current player states
  GameStates get gameState => _gameState;

  // Public setter to modify the current player states
  set gameState(GameStates value) {
    if (_gameState != value) {
      _gameState = value;

      if (backendReady) {
        final refPlayers =
            FirebaseDatabase.instance.ref().child('rooms/room1/state');
        refPlayers.set(this.toJson());
      }
    }
  }

  void fromJson(Map<String, dynamic> json) {
    final List<dynamic> playersJson = json['players'];
    players.clear(); // Clear existing players
    for (final playerJson in playersJson) {
      players.add(PlayerModel.fromJson(playerJson));
    }
    deck = DeckModel.fromJson(json['deck']);
    playerIdPlaying = json['playerIdPlaying'];
    playerIdAttacking = json['playerIdAttacking'];
    _gameState = GameStates.values.firstWhere(
      (e) => e.toString() == json['state'],
      orElse: () => GameStates.pickCardFromPiles,
    ); // Use a safe default value

    selectedCard = null; // Explicitly handle null
    if (json['selectedCard'] != null) {
      selectedCard = CardModel.fromJson(json['selectedCard']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'deck': deck.toJson(),
      'playerIdPlaying': playerIdPlaying,
      'playerIdAttacking': playerIdAttacking,
      'state': gameState.toString(),
      'selectedCard': selectedCard?.toJson(),
    };
  }

  String getPlayerName(final int index) {
    if (index < 0 || index >= players.length) {
      return 'No one';
    }
    return players[index].name;
  }

  CardModel? selectedCard;

  int get numPlayers => players.length;

  /// Initializes the game by setting up the decks, hands, and visibility.
  void initializeGame() {
    playerIdPlaying = 0;
    playerIdAttacking = -1;

    // Calculate number of decks
    // 1 deck for 2 & 3 players, 2 decks for 4 to 5 players, 3 decks for 6 to 7 players, etc.
    final int numDecks = (numPlayers - 2) ~/ 2;
    deck.shuffle(numberOfDecks: 1 + numDecks);

    for (final PlayerModel player in players) {
      for (final _ in Iterable.generate(9)) {
        player.addCardToHand(deck.cardsDeckPile.removeLast());
      }
      player.revealInitialCards();
    }

    if (deck.cardsDeckPile.isNotEmpty) {
      deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
    }

    gameState = GameStates.pickCardFromPiles;
  }

  void drawCard(BuildContext context, {required bool fromDiscardPile}) {
    if (gameState != GameStates.pickCardFromPiles) {
      showTurnNotification(context, "It's not your turn!");
      return;
    }

    if (fromDiscardPile && deck.cardsDeckDiscarded.isNotEmpty) {
      selectedCard = deck.cardsDeckDiscarded.removeLast();
      gameState = GameStates.flipAndSwap;
    } else if (!fromDiscardPile && deck.cardsDeckPile.isNotEmpty) {
      selectedCard = deck.cardsDeckPile.removeLast();
      gameState = GameStates.keepOrDiscard;
    } else {
      showTurnNotification(context, 'No cards available to draw!');
    }
  }

  void swapCard(int playerIndex, int gridIndex) {
    if (selectedCard == null ||
        !validGridIndex(players[playerIndex].hand, gridIndex)) {
      // Access player's hand directly
      return;
    }

    CardModel cardToSwap =
        players[playerIndex].hand[gridIndex]; // Access player's hand directly
    deck.cardsDeckDiscarded.add(cardToSwap);

    players[playerIndex].hand[gridIndex] =
        selectedCard!; // Access player's hand directly

    selectedCard = null;
  }

  bool validGridIndex(List<CardModel> hand, int index) {
    return index >= 0 && index < hand.length;
  }

  void revealAllRemainingCardsFor(int playerIndex) {
    final PlayerModel player = players[playerIndex];
    for (int indexCard = 0; indexCard < player.hand.length; indexCard++) {
      player.cardVisibility[indexCard] = true;
    }
  }

  void revealCard(BuildContext context, int playerIndex, int cardIndex) {
    if (!canCurrentPlayerAct(playerIndex)) {
      notifyCardUnavailable(context, 'Wait your turn!');
      return;
    }

    if (handleFlipOneCardState(context, playerIndex, cardIndex) ||
        handleFlipAndSwapState(context, playerIndex, cardIndex)) {
      if (this.isFinalTurn) {
        revealAllRemainingCardsFor(playerIndex);
        if (areAllCardsFromHandsRevealed()) {
          endGame(context);
        }
      }
      return;
    }

    notifyCardUnavailable(context, 'Not allowed at the moment!');
  }

  void endGame(BuildContext context) {
    showGameOverDialog(
      context,
      players,
      initializeGame,
    );
  }

  bool handleFlipOneCardState(
    BuildContext context,
    int playerIndex,
    int cardIndex,
  ) {
    if (gameState != GameStates.flipOneCard ||
        players[playerIndex].cardVisibility[cardIndex]) {
      return false;
    }

    players[playerIndex].cardVisibility[cardIndex] = true;
    gameState = GameStates.pickCardFromPiles;
    finalizeAction(context);
    return true;
  }

  bool handleFlipAndSwapState(
    BuildContext context,
    int playerIndex,
    int cardIndex,
  ) {
    if (gameState != GameStates.flipAndSwap) {
      return false;
    }

    players[playerIndex].cardVisibility[cardIndex] = true;
    swapCard(playerIndex, cardIndex);
    finalizeAction(context);
    return true;
  }

  void finalizeAction(BuildContext context) {
    advanceToNextPlayer(context);
  }

  bool canCurrentPlayerAct(int playerIndex) {
    return playerIdPlaying == playerIndex;
  }

  void notifyCardUnavailable(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  bool areAllCardRevealed(final int playerIndex) {
    return players[playerIndex]
        .cardVisibility
        .every((visible) => visible); // Access visibility directly
  }

  /// Checks if all players have revealed all their cards.
  bool areAllCardsFromHandsRevealed() {
    for (int playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
      if (!areAllCardRevealed(playerIndex)) {
        return false;
      }
    }
    return true;
  }

  void advanceToNextPlayer(BuildContext context) {
    if (isFinalTurn == false) {
      if (areAllCardRevealed(playerIdPlaying)) {
        playerIdAttacking = playerIdPlaying;
      }
    }
    playerIdPlaying = (playerIdPlaying + 1) % players.length;
    gameState = GameStates.pickCardFromPiles;
  }

  String getGameStateAsString() {
    /// Name of the currently active player.
    String playersName = getPlayerName(playerIdPlaying);

    /// Name of the player the active player needs to beat in the final round (if applicable).
    String playerAttackerName = getPlayerName(playerIdAttacking);

    /// Base text for the banner message.
    String inputText = 'It\'s your turn $playersName';

    /// Modifies the banner text if it's the final turn, indicating who the active player
    /// needs to beat.
    if (isFinalTurn) {
      inputText =
          'Final Round. $inputText. You have to beat $playerAttackerName';
    }

    return inputText;
  }
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

enum GameStates {
  notStarted,
  pickCardFromPiles,
  keepOrDiscard,
  flipOneCard,
  flipAndSwap,
  gameOver,
}
