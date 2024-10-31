import 'package:cards/widgets/playing_card.dart';

class Deck {
  int numberOfDecks = 0;

  List<PlayingCard> cardsDeckPile = [];
  List<PlayingCard> cardsDeckDiscarded = [];

  void shuffle({required final int numberOfDecks}) {
    this.numberOfDecks = numberOfDecks;
    List<String> suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    List<String> ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];

    // Generate the specified number of decks
    for (int deckCount = 0; deckCount < numberOfDecks; deckCount++) {
      for (String suit in suits) {
        for (String rank in ranks) {
          cardsDeckPile
              .add(PlayingCard(suit: suit, rank: rank, value: getValue(rank)));
        }
      }
      // Add Jokers to each deck
      cardsDeckPile.addAll([
        PlayingCard(suit: 'Joker', rank: 'Black', value: -2),
        PlayingCard(suit: 'Joker', rank: 'Red', value: -2),
      ]);
    }

    cardsDeckPile.shuffle();
  }

  int getValue(String rank) {
    if (rank == 'A') {
      return 1;
    }
    if (rank == 'K') {
      return 0;
    }
    if (rank == 'Q') {
      return 12;
    }
    if (rank == 'J') {
      return 11;
    }

    return int.tryParse(rank) ?? 0;
  }
}
