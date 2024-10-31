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
