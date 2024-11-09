class CardModel {
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      suit: json['suit'],
      rank: json['rank'],
      value: json['value'],
      partOfSet: json['partOfSet'] ?? false,
      isRevealed: json['isRevealed'] ?? false,
    );
  }
  CardModel({
    required this.suit,
    required this.rank,
    required this.value,
    this.partOfSet = false,
    this.isRevealed = false,
  });
  final String suit;
  final String rank;
  final int value;
  bool isRevealed = false;
  bool partOfSet;

  @override
  String toString() {
    return '$rank of $suit';
  }

  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
      'value': value,
      'partOfSet': partOfSet,
      'isRevealed': isRevealed,
    };
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
