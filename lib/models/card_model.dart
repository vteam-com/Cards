class CardModel {
  CardModel({
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

  static const List<String> suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
  static const List<String> ranks = [
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

  static int getValue(String rank) {
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
