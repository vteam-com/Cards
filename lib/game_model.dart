import 'dart:convert';
import 'package:cards/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel with ChangeNotifier {
  // Initialize with the first player by default

  GameModel({required this.playerNames}) {
    initializeGame();
  }
  List<PlayingCard> cardsInTheDeck = [];
  List<PlayingCard> discardedCards = [];
  List<List<PlayingCard>> playerHands = [];
  List<List<bool>> cardVisibility = [];
  final List<String> playerNames;
  int activePlayerIndex = 0;

  int get numPlayers => playerNames.length;
  String get activePlayerName => playerNames[activePlayerIndex];
  void initializeGame() {
    int numPlayers = playerNames.length;
    int numberOfDecks = numPlayers > 2 ? 2 : 1;
    cardsInTheDeck = generateDeck(numberOfDecks: numberOfDecks);

    playerHands = List.generate(numPlayers, (_) => []);
    cardVisibility = List.generate(numPlayers, (_) => []);

    for (int i = 0; i < numPlayers; i++) {
      for (int j = 0; j < 9; j++) {
        playerHands[i].add(cardsInTheDeck.removeLast());
        cardVisibility[i].add(false); // All cards are initially hidden
      }
      revealInitialCards(i);
    }
    notifyListeners();
  }

  void revealInitialCards(int playerIndex) {
    if (cardVisibility[playerIndex].length >= 2) {
      cardVisibility[playerIndex][0] = true;
      cardVisibility[playerIndex][1] = true;
    }
  }

  void toggleCardVisibility(int playerIndex, int cardIndex) {
    cardVisibility[playerIndex][cardIndex] =
        !cardVisibility[playerIndex][cardIndex];
    saveGameState(); // Save state after toggling visibility
    notifyListeners();
  }

  int calculatePlayerScore(int index) {
    int score = 0;
    for (int i = 0; i < playerHands[index].length; i++) {
      if (cardVisibility[index][i]) {
        // Only add the value of revealed cards
        score += playerHands[index][i]
            .value; // Assuming PlayingCard has a 'value' property
      }
    }
    return score;
  }

  void drawCard() {
    if (cardsInTheDeck.isNotEmpty) {
      var drawnCard = cardsInTheDeck.removeLast();
      discardedCards.add(drawnCard);
      saveGameState();
      notifyListeners();
    }
  }

  void setActivePlayer(int index) {
    activePlayerIndex = index;
    notifyListeners();
  }

  void nextPlayer() {
    activePlayerIndex = (activePlayerIndex + 1) % numPlayers;
    notifyListeners();
  }

  Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('playerHands', serializeHands(playerHands));
    prefs.setString('cardVisibility', serializeVisibility(cardVisibility));
  }

  Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    String? handsData = prefs.getString('playerHands');
    String? visibilityData = prefs.getString('cardVisibility');
    if (handsData != null) {
      playerHands = deserializeHands(handsData);
    }
    if (visibilityData != null) {
      cardVisibility = deserializeVisibility(visibilityData);
    }
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
