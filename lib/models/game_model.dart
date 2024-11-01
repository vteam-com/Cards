import 'package:cards/models/backend_model.dart';
import 'package:cards/models/deck_model.dart';
import 'package:cards/models/game_over_dialog.dart';
import 'package:cards/models/player_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
export 'package:cards/models/deck_model.dart';
export 'package:cards/models/player_model.dart';

class GameModel with ChangeNotifier {
  /// Creates a new game model.
  ///
  /// [gameRoomId] is the ID of the room this game is in.
  /// [names] is the list of player names.
  /// [isNewGame] indicates whether this is a new game or joining an existing one.
  GameModel({
    required this.gameRoomId,
    required final List<String> names,
    bool isNewGame = false,
  }) {
    // Initialize players from the list of names
    for (final String name in names) {
      players.add(PlayerModel(name: name));
    }
    if (isNewGame) {
      initializeGame();
    }
  }

  /// The ID of the game room.
  final String gameRoomId;

  /// List of players in the game.
  final List<PlayerModel> players = [];

  /// The deck of cards used in the game.
  DeckModel deck = DeckModel(1);

  /// The index of the player currently playing.
  int playerIdPlaying = 0;

  /// The index of the player being attacked in the final turn. -1 if not the final turn.
  int playerIdAttacking = -1;

  /// Whether the game is in the final turn.
  bool get isFinalTurn => playerIdAttacking != -1;

  /// The current state of the game.
  GameStates _gameState = GameStates.notStarted;

  /// The current state of the game.
  GameStates get gameState => _gameState;

  /// Sets the game state and updates the database if backend is ready.
  set gameState(GameStates value) {
    if (_gameState != value) {
      _gameState = value;

      if (backendReady) {
        final refPlayers =
            FirebaseDatabase.instance.ref().child('rooms/$gameRoomId');
        refPlayers.set(this.toJson());
      }
    }
  }

  /// The card currently selected by the player.
  CardModel? selectedCard;

  /// The number of players in the game.
  int get numPlayers => players.length;

  /// Updates the game model from a JSON object.
  void fromJson(Map<String, dynamic> json) {
    final List<dynamic> playersJson = json['players'];
    players.clear();
    for (final playerJson in playersJson) {
      players.add(PlayerModel.fromJson(playerJson));
    }
    deck = DeckModel.fromJson(json['deck']);
    playerIdPlaying = json['playerIdPlaying'];
    playerIdAttacking = json['playerIdAttacking'];
    _gameState = GameStates.values.firstWhere(
      (e) => e.toString() == json['state'],
      orElse: () => GameStates.pickCardFromPiles,
    );

    selectedCard = null;
    if (json['selectedCard'] != null) {
      selectedCard = CardModel.fromJson(json['selectedCard']);
    }
  }

  /// Converts the game model to a JSON object.
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

  /// Returns the name of the player at the given index.
  String getPlayerName(final int index) {
    if (index < 0 || index >= players.length) {
      return 'No one';
    }
    return players[index].name;
  }

  /// Initializes the game state, including dealing cards and setting the initial game state.
  void initializeGame() {
    playerIdPlaying = 0;
    playerIdAttacking = -1;

    // Calculate number of decks based on number of players.
    final int numDecks = (numPlayers - 2) ~/ 2;
    deck.shuffle(numberOfDecks: 1 + numDecks);

    // Deal 9 cards to each player and reveal the initial 3.
    for (final PlayerModel player in players) {
      for (final _ in Iterable.generate(9)) {
        player.addCardToHand(deck.cardsDeckPile.removeLast());
      }
      player.revealInitialCards();
    }

    // Add a card to the discard pile if the deck is not empty.
    if (deck.cardsDeckPile.isNotEmpty) {
      deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
    }
    gameState = GameStates.pickCardFromPiles;
  }

  /// Allows a player to draw a card, either from the discard pile or the deck.
  ///
  /// [context] is the BuildContext used for displaying snackbar messages.
  /// [fromDiscardPile] indicates whether to draw from the discard pile or the deck.
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

  /// Swaps the selected card with a card in the player's hand.
  ///
  /// [playerIndex] is the index of the player whose hand is being modified.
  /// [gridIndex] is the index of the card in the player's hand to swap.
  void swapCard(int playerIndex, int gridIndex) {
    if (selectedCard == null ||
        !validGridIndex(players[playerIndex].hand, gridIndex)) {
      return;
    }

    CardModel cardToSwap = players[playerIndex].hand[gridIndex];
    deck.cardsDeckDiscarded.add(cardToSwap);
    players[playerIndex].hand[gridIndex] = selectedCard!;
    selectedCard = null;
  }

  /// Checks if the given grid index is valid for the given hand.
  bool validGridIndex(List<CardModel> hand, int index) {
    return index >= 0 && index < hand.length;
  }

  /// Reveals all remaining cards for the specified player.
  ///
  /// [playerIndex] is the index of the player whose cards should be revealed.
  void revealAllRemainingCardsFor(int playerIndex) {
    final PlayerModel player = players[playerIndex];
    for (int indexCard = 0; indexCard < player.hand.length; indexCard++) {
      player.cardVisibility[indexCard] = true;
    }
  }

  /// Handles revealing a card, either for flipping or swapping.
  ///
  /// [context] is the BuildContext used for displaying snackbar messages.
  /// [playerIndex] is the index of the player revealing the card.
  /// [cardIndex] is the index of the card being revealed.
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

  /// Ends the game and displays the game over dialog.
  ///
  /// [context] is the BuildContext used for displaying the dialog.
  void endGame(BuildContext context) {
    showGameOverDialog(
      context,
      players,
      initializeGame,
    );
  }

  /// Handles the logic for flipping a card during the 'flipOneCard' game state.
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

  /// Handles the logic for flipping and swapping a card during the 'flipAndSwap' game state.
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

  /// Finalizes the current player's action and advances to the next player.
  void finalizeAction(BuildContext context) {
    advanceToNextPlayer(context);
  }

  /// Checks if the current player can perform an action.
  bool canCurrentPlayerAct(int playerIndex) {
    return playerIdPlaying == playerIndex;
  }

  /// Displays a snackbar message indicating that a card is unavailable.
  void notifyCardUnavailable(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Checks if all cards are revealed for a specific player.
  bool areAllCardRevealed(final int playerIndex) {
    return players[playerIndex].cardVisibility.every((visible) => visible);
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

  /// Advances the game to the next player's turn.
  void advanceToNextPlayer(BuildContext context) {
    if (isFinalTurn == false) {
      if (areAllCardRevealed(playerIdPlaying)) {
        playerIdAttacking = playerIdPlaying;
      }
    }
    playerIdPlaying = (playerIdPlaying + 1) % players.length;
    gameState = GameStates.pickCardFromPiles;
  }

  /// Returns a string representing the current game state, including the current player's name
  /// and the attacker's name if it's the final turn.
  String getGameStateAsString() {
    String playersName = getPlayerName(playerIdPlaying);
    String playerAttackerName = getPlayerName(playerIdAttacking);

    String inputText = 'It\'s your turn $playersName';

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
