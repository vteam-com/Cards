class PlayingCard {
  PlayingCard({
    required this.suit,
    required this.rank,
    required this.value,
    this.partOfSet = false,
  });
  final String suit;
  final String rank;
  final int value;
  bool partOfSet;

  @override
  String toString() {
    return '$rank of $suit';
  }
}

List<PlayingCard> generateDeck({int numberOfDecks = 1}) {
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
  List<PlayingCard> deck = [];

  // Generate the specified number of decks
  for (int deckCount = 0; deckCount < numberOfDecks; deckCount++) {
    for (String suit in suits) {
      for (String rank in ranks) {
        deck.add(PlayingCard(suit: suit, rank: rank, value: getValue(rank)));
      }
    }
    // Add Jokers to each deck
    deck.addAll([
      PlayingCard(suit: 'Joker', rank: 'Black', value: -2),
      PlayingCard(suit: 'Joker', rank: 'Red', value: -2),
    ]);
  }

  deck.shuffle();
  return deck;
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
