import 'package:cards/widgets/playing_card.dart';

class Player {
  Player({required this.name});
  final String name;
  int score = 0;
  List<PlayingCard> hand = [];
  List<bool> cardVisibility = [];

  void addCardToHand(PlayingCard card) {
    hand.add(card);
    cardVisibility.add(false);
  }

  void revealInitialCards() {
    for (int i = 0; i < hand.length; i++) {
      if (i < 6 || i == 7 || i == 8) {
        cardVisibility[i] = true;
      }
    }
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < hand.length; i++) {
      if (cardVisibility[i] && !hand[i].partOfSet) {
        score += hand[i].value;
      }
    }
    return score;
  }
}
