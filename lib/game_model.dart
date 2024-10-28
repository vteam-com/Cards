import 'dart:convert';
import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel with ChangeNotifier {
  GameModel({required this.playerNames}) {
    initializeGame();
  }
  // Player setup
  final List<String> playerNames;
  int currentPlayerIndex = 0;

  // Game state initialization
  List<PlayingCard> cardsDeckPile = [];
  List<PlayingCard> cardsDeckDiscarded = [];
  List<List<PlayingCard>> playerHands = [];
  List<List<bool>> cardVisibility = [];

  // Private field to hold the state
  CurrentPlayerStates _currentPlayerStates =
      CurrentPlayerStates.pickCardFromDeck;

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

  int get numPlayers => playerNames.length;
  String get activePlayerName => playerNames[currentPlayerIndex];

  void initializeGame() {
    int numberOfDecks = numPlayers > 2 ? 2 : 1;
    cardsDeckPile = generateDeck(numberOfDecks: numberOfDecks);

    playerHands = List.generate(numPlayers, (_) => []);
    cardVisibility = List.generate(numPlayers, (_) => []);

    for (int i = 0; i < numPlayers; i++) {
      for (int j = 0; j < 9; j++) {
        playerHands[i].add(cardsDeckPile.removeLast());
        cardVisibility[i].add(false);
      }
      revealInitialCards(i);
    }

    if (cardsDeckPile.isNotEmpty) {
      cardsDeckDiscarded.add(cardsDeckPile.removeLast());
    }

    notifyListeners();
  }

  void drawCard(BuildContext context, {required bool fromDiscardPile}) {
    if (currentPlayerStates != CurrentPlayerStates.pickCardFromDeck) {
      showTurnNotification(context, "It's not your turn!");
      return;
    }

    if (fromDiscardPile && cardsDeckDiscarded.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckDiscarded.removeLast();
    } else if (!fromDiscardPile && cardsDeckPile.isNotEmpty) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckPile.removeLast();
    } else {
      showTurnNotification(context, 'No cards available to draw!');
      return;
    }

    currentPlayerStates = CurrentPlayerStates.keepOrDiscard;
    notifyListeners();
  }

  void swapCard(int playerIndex, int gridIndex) {
    if (cardPickedUpFromDeckOrDiscarded == null ||
        !validGridIndex(playerHands[playerIndex], gridIndex)) {
      return;
    }

    PlayingCard cardToSwap = playerHands[playerIndex][gridIndex];
    cardsDeckDiscarded.add(cardToSwap);
    playerHands[playerIndex][gridIndex] = cardPickedUpFromDeckOrDiscarded!;
    cardPickedUpFromDeckOrDiscarded = null;
    saveGameState();
    notifyListeners();
  }

  bool validGridIndex(List<PlayingCard> hand, int index) {
    return index >= 0 && index < hand.length;
  }

  void revealCard(BuildContext context, int playerIndex, int cardIndex) {
    if (!canCurrentPlayerAct(playerIndex)) {
      notifyCardUnavailable(context, 'Wait your turn!');
      return;
    }

    if (currentPlayerStates == CurrentPlayerStates.flipOneCard) {
      if (!cardVisibility[playerIndex][cardIndex]) {
        cardVisibility[playerIndex][cardIndex] = true;
        currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
        saveGameState();
        notifyListeners();
        nextPlayer();
      } else {
        notifyCardUnavailable(context, 'Action not allowed in current state!');
      }
      return;
    }

    // Swapping can be allowed directly with a revealed or hidden card
    if (currentPlayerStates == CurrentPlayerStates.flipAndSwap) {
      cardVisibility[playerIndex][cardIndex] = true;
      swapCard(playerIndex, cardIndex);
      currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
      saveGameState();
      notifyListeners();
      nextPlayer();
      return;
    }
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
    if (cardVisibility[playerIndex].length >= 2) {
      cardVisibility[playerIndex][0] = true;
      cardVisibility[playerIndex][1] = true;
    }
  }

  int calculatePlayerScore(int index) {
    int score = 0;
    List<bool> markedForZeroScore =
        List.filled(playerHands[index].length, false);

    // Example of using markIfSameRank
    for (final indices in [
      [0, 1, 2],
      [0, 3, 6],
    ]) {
      markIfSameRank(playerHands[index], markedForZeroScore, indices);
    }

    for (int i = 0; i < playerHands[index].length; i++) {
      if (cardVisibility[index][i] && !playerHands[index][i].partOfSet) {
        score += playerHands[index][i].value;
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

  void advanceToNextPlayer() {
    currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
    currentPlayerIndex = (currentPlayerIndex + 1) % playerNames.length;
  }

  void nextPlayer() {
    advanceToNextPlayer();
    notifyListeners();
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('playerHands', serializeHands(playerHands));
    prefs.setString('cardVisibility', serializeVisibility(cardVisibility));
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
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

enum CurrentPlayerStates {
  pickCardFromDeck,
  keepOrDiscard,
  flipOneCard,
  flipAndSwap,
}

String getInstructionToPlayer(CurrentPlayerStates state) {
  switch (state) {
    case CurrentPlayerStates.pickCardFromDeck:
      return 'Draw a card from the deck or the discard pile.';
    case CurrentPlayerStates.keepOrDiscard:
      return 'Keep, or discard?';
    case CurrentPlayerStates.flipOneCard:
      return 'Flip one card.';
    case CurrentPlayerStates.flipAndSwap:
      return 'Swap one\nof your\ncards.';
  }
}
