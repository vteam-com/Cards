import 'dart:convert';
import 'package:cards/models/player.dart';
import 'package:cards/screens/game_over_screen.dart';
import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel with ChangeNotifier {
  GameModel({required final List<String> names, required this.gameRoomId}) {
    // Initialize players from the list of names
    for (final String name in names) {
      players.add(Player(name: name));
    }
    initializeGame();
  }
  final String gameRoomId;
  // Player setup
  final List<Player> players = [];

  late int currentPlayerIndex;
  late bool finalTurn;
  late int playerIndexOfAttacker;

  // Game state initialization
  List<PlayingCard> cardsDeckPile = [];
  List<PlayingCard> cardsDeckDiscarded = [];

  // Private field to hold the state
  CurrentPlayerStates _currentPlayerStates =
      CurrentPlayerStates.pickCardFromPiles;

  String getPlayerName(final int index) {
    if (index == -1) {
      return 'No one';
    }
    return players[index].name;
  }

  // Public getter to access the current player states
  CurrentPlayerStates get currentPlayerStates => _currentPlayerStates;

  // Public setter to modify the current player states
  set currentPlayerStates(CurrentPlayerStates value) {
    if (_currentPlayerStates != value) {
      _currentPlayerStates = value;

      notifyListeners();
    }
  }

  PlayingCard? cardPickedUpFromDeckOrDiscarded;

  int get numPlayers => players.length;

  String get activePlayerName {
    if (currentPlayerIndex >= 0 && currentPlayerIndex < players.length) {
      return players[currentPlayerIndex].name;
    }
    return '';
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

  /// Initializes the game by setting up the decks, hands, and visibility.
  void initializeGame() {
    currentPlayerIndex = 0;
    finalTurn = false;
    playerIndexOfAttacker = -1;

    final int numberOfDecks = numPlayers > 2 ? 2 : 1;
    cardsDeckPile = generateDeck(numberOfDecks: numberOfDecks);

    for (int playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
      for (int j = 0; j < 9; j++) {
        players[playerIndex].addCardToHand(
          cardsDeckPile.removeLast(),
        ); // Add card to player's hand directly
      }
      revealInitialCards(playerIndex);
    }

    if (cardsDeckPile.isNotEmpty) {
      cardsDeckDiscarded.add(cardsDeckPile.removeLast());
    }

    notifyListeners();
  }

  void drawCard(BuildContext context, {required bool fromDiscardPile}) {
    if (currentPlayerStates != CurrentPlayerStates.pickCardFromPiles) {
      showTurnNotification(context, "It's not your turn!");
      return;
    }

    if (fromDiscardPile && cardsDeckDiscarded.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckDiscarded.removeLast();
      currentPlayerStates = CurrentPlayerStates.flipAndSwap;
    } else if (!fromDiscardPile && cardsDeckPile.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckPile.removeLast();
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

    PlayingCard cardToSwap =
        players[playerIndex].hand[gridIndex]; // Access player's hand directly
    cardsDeckDiscarded.add(cardToSwap);

    players[playerIndex].hand[gridIndex] =
        cardPickedUpFromDeckOrDiscarded!; // Access player's hand directly

    cardPickedUpFromDeckOrDiscarded = null;
    saveGameState();
  }

  bool validGridIndex(List<PlayingCard> hand, int index) {
    return index >= 0 && index < hand.length;
  }

  void revealAllRemainingCardsFor(int playerIndex) {
    final Player player = players[playerIndex];
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

  void revealInitialCards(int playerIndex) {
    players[playerIndex].cardVisibility[4] = true; // Access visibility directly
    players[playerIndex].cardVisibility[7] = true; // Access visibility directly
  }

  int calculatePlayerScore(int playerIndex) {
    int score = 0;
    List<bool> markedForZeroScore =
        List.filled(players[playerIndex].hand.length, false);

    List<List<int>> checkingIndices = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // [0, 4, 8], // Diagonal from top-left to bottom-right
      // [2, 4, 6], // Diagonal from top-right to bottom-left
    ];

    for (final List<int> indices in checkingIndices) {
      markIfSameRank(players[playerIndex].hand, markedForZeroScore, indices);
    }

    for (int i = 0; i < players[playerIndex].hand.length; i++) {
      if (players[playerIndex].cardVisibility[i] &&
          !players[playerIndex].hand[i].partOfSet) {
        score += players[playerIndex].hand[i].value;
      }
    }

    return score;
  }

  void markIfSameRank(
    List<PlayingCard> hand,
    List<bool> markedForZeroScore,
    List<int> indices,
  ) {
    if (indices.length == 3 &&
        areAllTheSameRankAndNotAlreadyUsed(
          hand[indices[0]],
          hand[indices[1]],
          hand[indices[2]],
        )) {
      for (int index in indices) {
        hand[index].partOfSet = true;
      }
    }
  }

  bool areAllTheSameRankAndNotAlreadyUsed(
    PlayingCard card1,
    PlayingCard card2,
    PlayingCard card3,
  ) {
    return !(card1.partOfSet || card2.partOfSet || card3.partOfSet) &&
        areAllTheSameRank(card1.rank, card2.rank, card3.rank);
  }

  bool areAllTheSameRank(String rank1, String rank2, String rank3) {
    return rank1 == rank2 && rank2 == rank3;
  }

  bool areAllCardRevealed(final int playerIndex) {
    return players[playerIndex]
        .cardVisibility
        .every((visible) => visible); // Access visibility directly
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
      jsonEncode(cardsDeckPile.map((card) => card.toString()).toList()),
    );
    prefs.setString(
      'cardsDeckDiscarded',
      jsonEncode(cardsDeckDiscarded.map((card) => card.toString()).toList()),
    );
    // Consider saving other game state variables like cardsDeckPile, cardsDeckDiscarded, etc. as needed
  }

  String serializeHands(List<List<PlayingCard>> hands) {
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

  List<List<PlayingCard>> deserializeHands(String data) {
    return (jsonDecode(data) as List).map<List<PlayingCard>>((hand) {
      return (hand as List).map<PlayingCard>((cardData) {
        return PlayingCard(
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
