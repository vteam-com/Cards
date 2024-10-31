import 'package:cards/models/card_model.dart';
export 'package:cards/models/card_model.dart';

class DeckModel {
  int numberOfDecks = 0;

  List<CardModel> cardsDeckPile = [];
  List<CardModel> cardsDeckDiscarded = [];

  void shuffle({required final int numberOfDecks}) {
    this.numberOfDecks = numberOfDecks;

    // Generate the specified number of decks
    for (int deckCount = 0; deckCount < numberOfDecks; deckCount++) {
      for (String suit in CardModel.suits) {
        for (String rank in CardModel.ranks) {
          cardsDeckPile.add(
            CardModel(
              suit: suit,
              rank: rank,
              value: CardModel.getValue(rank),
            ),
          );
        }
      }
      // Add Jokers to each deck
      cardsDeckPile.addAll([
        CardModel(suit: 'Joker', rank: 'Black', value: -2),
        CardModel(suit: 'Joker', rank: 'Red', value: -2),
      ]);
    }

    cardsDeckPile.shuffle();
  }
}
