import 'package:cards/models/card_model.dart';
export 'package:cards/models/card_model.dart';

class PlayerModel {
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    List<CardModel> hand = [];
    for (var cardJson in json['hand']) {
      hand.add(CardModel.fromJson(cardJson));
    }

    List<bool> cardVisibility = [];
    for (var visibility in json['cardVisibility']) {
      cardVisibility.add(visibility);
    }

    return PlayerModel(
      name: json['name'],
    )
      ..hand = hand
      ..cardVisibility = cardVisibility;
  }
  PlayerModel({required this.name});
  final String name;
  int get sumOfRevealedCards => _getSumOfCardsInHand();
  List<CardModel> hand = [];
  List<bool> cardVisibility = [];

  void addCardToHand(CardModel card) {
    hand.add(card);
    cardVisibility.add(false);
  }

  void revealInitialCards() {
    cardVisibility[4] = true; // Access visibility directly
    cardVisibility[7] = true; // Access visibility directly
  }

  int _getSumOfCardsInHand() {
    int score = 0;
    List<bool> markedForZeroScore = List.filled(hand.length, false);

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
      markIfSameRank(hand, markedForZeroScore, indices);
    }

    for (int i = 0; i < hand.length; i++) {
      if (cardVisibility[i] && !hand[i].partOfSet) {
        score += hand[i].value;
      }
    }

    return score;
  }

  void markIfSameRank(
    List<CardModel> hand,
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
    CardModel card1,
    CardModel card2,
    CardModel card3,
  ) {
    return !(card1.partOfSet || card2.partOfSet || card3.partOfSet) &&
        areAllTheSameRank(card1.rank, card2.rank, card3.rank);
  }

  bool areAllTheSameRank(String rank1, String rank2, String rank3) {
    return rank1 == rank2 && rank2 == rank3;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hand': hand.map((CardModel card) => card.toJson()).toList(),
      'cardVisibility': cardVisibility,
    };
  }
}
