import 'dart:convert';
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
  late int currentPlayerIndex;
  late int playerIndexOfAttacker;
  late bool finalTurn;

  // Private field to hold the state
  CurrentPlayerStates _currentPlayerStates = CurrentPlayerStates.notStarted;
  // Public getter to access the current player states
  CurrentPlayerStates get currentPlayerStates => _currentPlayerStates;

  // Public setter to modify the current player states
  set currentPlayerStates(CurrentPlayerStates value) {
    if (_currentPlayerStates != value) {
      _currentPlayerStates = value;

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
    currentPlayerIndex = json['currentPlayerIndex'];
    playerIndexOfAttacker = json['playerIndexOfAttacker'];
    finalTurn = json['finalTurn'];
    _currentPlayerStates = CurrentPlayerStates.values.firstWhere(
      (e) => e.toString() == json['currentPlayerStates'],
      orElse: () => CurrentPlayerStates.pickCardFromPiles,
    ); // Use a safe default value

    cardPickedUpFromDeckOrDiscarded = null; // Explicitly handle null
    if (json['cardPickedUpFromDeckOrDiscarded'] != null) {
      cardPickedUpFromDeckOrDiscarded =
          CardModel.fromJson(json['cardPickedUpFromDeckOrDiscarded']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'deck': deck.toJson(),
      'currentPlayerIndex': currentPlayerIndex,
      'playerIndexOfAttacker': playerIndexOfAttacker,
      'finalTurn': finalTurn,
      'currentPlayerStates': currentPlayerStates.toString(),
      'cardPickedUpFromDeckOrDiscarded':
          cardPickedUpFromDeckOrDiscarded?.toJson(),
    };
  }

  String getPlayerName(final int index) {
    if (index < 0 || index >= players.length) {
      return 'No one';
    }
    return players[index].name;
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

    currentPlayerStates = CurrentPlayerStates.pickCardFromPiles;
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
    finalizeAction(context);
    return true;
  }

  void finalizeAction(BuildContext context) {
    advanceToNextPlayer(context);
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
        finalTurn = true;
      }
    }
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    currentPlayerStates = CurrentPlayerStates.pickCardFromPiles;
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
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

enum CurrentPlayerStates {
  notStarted,
  pickCardFromPiles,
  keepOrDiscard,
  flipOneCard,
  flipAndSwap,
  gameOver,
}
