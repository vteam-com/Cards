import 'dart:convert';
import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel with ChangeNotifier {
  // Initialize with the first player by default

  GameModel({required this.playerNames}) {
    initializeGame();
  }

  List<PlayingCard> cardsDeckPile = [];
  List<PlayingCard> cardsDeckDiscarded = [];

  List<List<PlayingCard>> playerHands = [];

  List<List<bool>> cardVisibility = [];

  final List<String> playerNames;

  int currentPlayerIndex = 0;

  int get numPlayers => playerNames.length;

  String get activePlayerName => playerNames[currentPlayerIndex];

  // This ensures the player has picked or drawn a card during their turn
  CurrentPlayerStates currentPlayerStates =
      CurrentPlayerStates.pickCardFromDeck;
  PlayingCard? cardPickedUpFromDeckOrDiscarded;

  void initializeGame() {
    int numPlayers = playerNames.length;
    int numberOfDecks = numPlayers > 2 ? 2 : 1;
    cardsDeckPile = generateDeck(numberOfDecks: numberOfDecks);

    playerHands = List.generate(numPlayers, (_) => []);
    cardVisibility = List.generate(numPlayers, (_) => []);

    for (int i = 0; i < numPlayers; i++) {
      for (int j = 0; j < 9; j++) {
        playerHands[i].add(cardsDeckPile.removeLast());
        cardVisibility[i].add(false); // All cards are initially hidden
      }
      revealInitialCards(i);
    }

    // Discard the top card of the deck
    if (cardsDeckPile.isNotEmpty) {
      cardsDeckDiscarded.add(cardsDeckPile.removeLast());
    }

    notifyListeners();
  }

  void advanceToNextPlayer() {
    currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;
    currentPlayerIndex = (currentPlayerIndex + 1) % playerNames.length;
  }

  // Ensure that only the active player can draw a card
  void playerDrawsFromDeck(BuildContext context) {
    if (currentPlayerStates == CurrentPlayerStates.pickCardFromDeck &&
        cardsDeckPile.isNotEmpty &&
        currentPlayerIndex == currentPlayerIndex) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckPile.removeLast();

      // Restrict further picking in the same turn
      currentPlayerStates = CurrentPlayerStates.takeKeepOrDiscard;

      notifyListeners();
    } else {
      showTurnNotification(context, "It's not your turn!");
    }
  }

  // Ensure that only the active player can draw a card
  void playerDrawsFromDiscardedDeck(BuildContext context) {
    if (currentPlayerStates == CurrentPlayerStates.pickCardFromDeck &&
        cardsDeckPile.isNotEmpty &&
        currentPlayerIndex == currentPlayerIndex) {
      cardPickedUpFromDeckOrDiscarded = cardsDeckDiscarded.removeLast();

      // Restrict further picking in the same turn
      currentPlayerStates = CurrentPlayerStates.takeKeepOrDiscard;

      notifyListeners();
    } else {
      showTurnNotification(context, "It's not your turn!");
    }
  }

  /// Swaps a card in the player's hand with a card picked up from the deck or discard pile.
  ///
  /// If a card has been picked up and is available for swapping, this method
  /// swaps the specified card from the player's hand with the picked-up card.
  /// The swapped card from the player's hand is then moved to the discard pile.
  ///
  /// The method ensures that:
  /// - The card swap occurs within valid indices of the player's hand.
  /// - The card picked up is not null.
  ///
  /// After successfully swapping the cards, the game state is saved,
  /// and listeners are notified to update the UI.
  ///
  /// [playerIndex] - The index of the player whose card is to be swapped.
  /// [gridIndex] - The index of the card in the player's hand that will be swapped.
  void swapCard(int playerIndex, int gridIndex) {
    if (cardPickedUpFromDeckOrDiscarded == null) {
      // If no card has been picked up, the swap cannot occur
      return;
    }

    if (playerHands[playerIndex].isNotEmpty &&
        gridIndex >= 0 &&
        gridIndex < playerHands[playerIndex].length) {
      // Swap the player's card with the picked-up card
      PlayingCard cardToSwap = playerHands[playerIndex][gridIndex];

      // Add the player's card to the discard pile
      cardsDeckDiscarded.add(cardToSwap);

      // Place the picked-up card in the player's hand at the same position
      playerHands[playerIndex][gridIndex] = cardPickedUpFromDeckOrDiscarded!;

      // Clear the cardPickedUpFromDeckOrDiscarded after the swap
      cardPickedUpFromDeckOrDiscarded = null;

      // Save state and notify listeners to update UI
      saveGameState();
      notifyListeners();
    }
  }

  void revealInitialCards(int playerIndex) {
    if (cardVisibility[playerIndex].length >= 2) {
      cardVisibility[playerIndex][0] = true;
      cardVisibility[playerIndex][1] = true;
    }
  }

  void revealCard(
    BuildContext context,
    int playerIndex,
    int cardIndex,
  ) {
    if (currentPlayerIndex == playerIndex &&
        !cardVisibility[playerIndex][cardIndex]) {
      if (currentPlayerStates == CurrentPlayerStates.flipOneCard ||
          currentPlayerStates == CurrentPlayerStates.flipAndSwap) {
        cardVisibility[playerIndex][cardIndex] = true;

        if (currentPlayerStates == CurrentPlayerStates.flipAndSwap) {
          swapCard(playerIndex, cardIndex);
        }
        currentPlayerStates = CurrentPlayerStates.pickCardFromDeck;

        saveGameState(); // Save state after changing visibility
        notifyListeners();
        nextPlayer();
      }
    } else {
      showTurnNotification(context, "It's not your turn!");
    }
  }

  bool areAllTheSameRank(
    final String rank1,
    final String rank2,
    final String rank3,
  ) {
    return rank1 == rank2 && rank2 == rank3;
  }

  bool areAllTheSameRankAndNotAlreadyUsed(
    final PlayingCard card1,
    final PlayingCard card2,
    final PlayingCard card3,
  ) {
    if (card1.partOfSet || card2.partOfSet || card3.partOfSet) {
      return false; // If any of the cards are already part of a set, return false
    }
    return areAllTheSameRank(card1.rank, card2.rank, card3.rank);
  }

  void markIfSameRankHorizontal(
    List<PlayingCard> hand,
    List<bool> markedForZeroScore,
    int startIndex,
  ) {
    if (areAllTheSameRankAndNotAlreadyUsed(
      hand[startIndex],
      hand[startIndex + 1],
      hand[startIndex + 2],
    )) {
      hand[startIndex + 0].partOfSet = true;
      hand[startIndex + 1].partOfSet = true;
      hand[startIndex + 2].partOfSet = true;
    }
  }

  void markIfSameRankVertical(
    List<PlayingCard> hand,
    List<bool> markedForZeroScore,
    int startIndex,
  ) {
    if (areAllTheSameRankAndNotAlreadyUsed(
      hand[startIndex + 0],
      hand[startIndex + 3],
      hand[startIndex + 6],
    )) {
      hand[startIndex + 0].partOfSet = true;
      hand[startIndex + 3].partOfSet = true;
      hand[startIndex + 6].partOfSet = true;
    }
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

  int calculatePlayerScore(int index) {
    int score = 0;
    List<bool> markedForZeroScore =
        List.filled(playerHands[index].length, false);

    // Check for three identical ranks in a horizontally
    markIfSameRank(
      playerHands[index],
      markedForZeroScore,
      [0, 1, 2],
    ); // Horizontal
    // Check for three identical ranks in a horizontally
    markIfSameRank(
      playerHands[index],
      markedForZeroScore,
      [0, 3, 6],
    ); // Vertical

    // Calculate the score
    for (int i = 0; i < playerHands[index].length; i++) {
      if (cardVisibility[index][i] && !playerHands[index][i].partOfSet) {
        // Add value of visible and non-zero-marked cards
        score += playerHands[index][i].value;
      }
    }

    return score;
  }

  void setActivePlayer(int index) {
    currentPlayerIndex = index;
    notifyListeners();
  }

  void nextPlayer() {
    setActivePlayer((currentPlayerIndex + 1) % numPlayers);
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('playerHands', serializeHands(playerHands));
    prefs.setString('cardVisibility', serializeVisibility(cardVisibility));
  }

  String serializeHands(List<List<PlayingCard>> hands) {
    return jsonEncode(
      hands.map((hand) {
        return hand.map((card) {
          return {'suit': card.suit, 'rank': card.rank, 'value': card.value};
        }).toList();
      }).toList(),
    );
  }

  List<List<PlayingCard>> deserializeHands(String data) {
    List<dynamic> jsonData = jsonDecode(data);
    return jsonData.map<List<PlayingCard>>((hand) {
      return hand.map<PlayingCard>((cardData) {
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
    List<dynamic> jsonData = jsonDecode(data);
    return jsonData
        .map<List<bool>>(
          (visibilityList) =>
              visibilityList.map<bool>((item) => item as bool).toList(),
        )
        .toList();
  }
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(
        seconds: 2,
      ), // Duration for which the SnackBar will be visible
    ),
  );
}

enum CurrentPlayerStates {
  pickCardFromDeck,
  takeKeepOrDiscard,
  flipOneCard,
  flipAndSwap,
}

String getInstructionToPlayer(CurrentPlayerStates state) {
  switch (state) {
    case CurrentPlayerStates.pickCardFromDeck:
      return 'Pick a card from the deck or the discard pile';
    case CurrentPlayerStates.takeKeepOrDiscard:
      return 'Take, keep, or discard';
    case CurrentPlayerStates.flipOneCard:
      return 'Flip one card';
    case CurrentPlayerStates.flipAndSwap:
      return 'Swap one\nof your\ncards';
  }
}
