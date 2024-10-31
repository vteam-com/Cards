import 'dart:convert';
import 'package:cards/models/deck_model.dart';
import 'package:cards/models/game_over_dialog.dart';
import 'package:cards/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:cards/models/deck_model.dart';
export 'package:cards/models/player_model.dart';

class GameModel with ChangeNotifier {
  GameModel({required final List<String> names, required this.gameRoomId}) {
    // Initialize players from the list of names
    for (final String name in names) {
      players.add(PlayerModel(name: name));
    }
    initializeGame();
  }
  final String gameRoomId;
  final List<PlayerModel> players = [];
  final DeckModel deck = DeckModel();
  late int currentPlayerIndex;
  late int playerIndexOfAttacker;
  late bool finalTurn;

  // Private field to hold the state
  CurrentPlayerStates _currentPlayerStates =
      CurrentPlayerStates.pickCardFromPiles;
  // Public getter to access the current player states
  CurrentPlayerStates get currentPlayerStates => _currentPlayerStates;

  String getPlayerName(final int index) {
    if (index == -1) {
      return 'No one';
    }
    return players[index].name;
  }

  // Public setter to modify the current player states
  set currentPlayerStates(CurrentPlayerStates value) {
    if (_currentPlayerStates != value) {
      _currentPlayerStates = value;

      notifyListeners();
    }
  }

  CardModel? cardPickedUpFromDeckOrDiscarded;

  int get numPlayers => players.length;

  /// Initializes the game by setting up the decks, hands, and visibility.
  void initializeGame() {
    currentPlayerIndex = 0;
    finalTurn = false;
    playerIndexOfAttacker = -1;

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

    notifyListeners();
  }

  void drawCard(BuildContext context, {required bool fromDiscardPile}) {
    if (currentPlayerStates != CurrentPlayerStates.pickCardFromPiles) {
      showTurnNotification(context, "It's not your turn!");
      return;
    }

    if (fromDiscardPile && deck.cardsDeckDiscarded.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = deck.cardsDeckDiscarded.removeLast();
      currentPlayerStates = CurrentPlayerStates.flipAndSwap;
    } else if (!fromDiscardPile && deck.cardsDeckPile.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = deck.cardsDeckPile.removeLast();
      currentPlayerStates = CurrentPlayerStates.keepOrDiscard;
    } else {
      showTurnNotification(context, 'No cards available to draw!');
    }
    notifyListeners();
  }

  void swapCard(int playerIndex, int gridIndex) {
    if (cardPickedUpFromDeckOrDiscarded == null ||
        !validGridIndex(players[playerIndex].hand, gridIndex)) {
      // Access player's hand directly
      return;
    }

    CardModel cardToSwap =
        players[playerIndex].hand[gridIndex]; // Access player's hand directly
    deck.cardsDeckDiscarded.add(cardToSwap);

    players[playerIndex].hand[gridIndex] =
        cardPickedUpFromDeckOrDiscarded!; // Access player's hand directly

    cardPickedUpFromDeckOrDiscarded = null;
    saveGameState();
  }

  bool validGridIndex(List<CardModel> hand, int index) {
    return index >= 0 && index < hand.length;
  }

  void revealAllRemainingCardsFor(int playerIndex) {
    final PlayerModel player = players[playerIndex];
    for (int indexCard = 0; indexCard < player.hand.length; indexCard++) {
      player.cardVisibility[indexCard] = true;
    }
    notifyListeners();
  }

  void revealCard(BuildContext context, int playerIndex, int cardIndex) {
    if (!canCurrentPlayerAct(playerIndex)) {
      notifyCardUnavailable(context, 'Wait your turn!');
      return;
    }

    if (handleFlipOneCardState(context, playerIndex, cardIndex) ||
        handleFlipAndSwapState(context, playerIndex, cardIndex)) {
      if (this.finalTurn) {
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
    if (currentPlayerStates != CurrentPlayerStates.flipOneCard ||
        players[playerIndex].cardVisibility[cardIndex]) {
      return false;
    }

    players[playerIndex].cardVisibility[cardIndex] = true;
    currentPlayerStates = CurrentPlayerStates.pickCardFromPiles;
    finalizeAction(context);
    return true;
  }

  bool handleFlipAndSwapState(
    BuildContext context,
    int playerIndex,
    int cardIndex,
  ) {
    if (currentPlayerStates != CurrentPlayerStates.flipAndSwap) {
      return false;
    }

    players[playerIndex].cardVisibility[cardIndex] = true;
    swapCard(playerIndex, cardIndex);
    currentPlayerStates = CurrentPlayerStates.pickCardFromPiles;
    finalizeAction(context);
    return true;
  }

  void finalizeAction(BuildContext context) {
    advanceToNextPlayer(context);
    saveGameState();
    notifyListeners();
  }

  bool canCurrentPlayerAct(int playerIndex) {
    return currentPlayerIndex == playerIndex;
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
    if (finalTurn == false) {
      if (areAllCardRevealed(currentPlayerIndex)) {
        playerIndexOfAttacker = currentPlayerIndex;
        triggerStartForRound(context);
      }
    }
    currentPlayerStates = CurrentPlayerStates.pickCardFromPiles;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    // Directly access the player's hand from the players list
    prefs.setString(
      'playerHands',
      serializeHands(players.map((p) => p.hand).toList()),
    );
    prefs.setString(
      'cardVisibility',
      serializeVisibility(
        players.map((p) => p.cardVisibility).toList(),
      ),
    ); // Fix: Save cardVisibility per player
    prefs.setInt('currentPlayerIndex', currentPlayerIndex);
    prefs.setBool('finalTurn', finalTurn);
    prefs.setInt('playerIndexOfAttacker', playerIndexOfAttacker);
    prefs.setString(
      'cardsDeckPile',
      jsonEncode(deck.cardsDeckPile.map((card) => card.toString()).toList()),
    );
    prefs.setString(
      'cardsDeckDiscarded',
      jsonEncode(
        deck.cardsDeckDiscarded.map((card) => card.toString()).toList(),
      ),
    );
    // Consider saving other game state variables like cardsDeckPile, cardsDeckDiscarded, etc. as needed
  }

  String serializeHands(List<List<CardModel>> hands) {
    return jsonEncode(
      hands.map((hand) {
        return hand
            .map(
              (card) => {
                'suit': card.suit,
                'rank': card.rank,
                'value': card.value,
              },
            )
            .toList();
      }).toList(),
    );
  }

  List<List<CardModel>> deserializeHands(String data) {
    return (jsonDecode(data) as List).map<List<CardModel>>((hand) {
      return (hand as List).map<CardModel>((cardData) {
        return CardModel(
          suit: cardData['suit'],
          rank: cardData['rank'],
          value: cardData['value'],
        );
      }).toList();
    }).toList();
  }

  String serializeVisibility(List<List<bool>> visibility) {
    return jsonEncode(visibility);
  }

  List<List<bool>> deserializeVisibility(String data) {
    return (jsonDecode(data) as List).map<List<bool>>((visibilityList) {
      return List<bool>.from(visibilityList);
    }).toList();
  }

  void triggerStartForRound(BuildContext context) {
    finalTurn = true;
    notifyListeners();
  }
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

enum CurrentPlayerStates {
  pickCardFromPiles,
  keepOrDiscard,
  flipOneCard,
  flipAndSwap,
  gameOver,
}
