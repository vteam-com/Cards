/// Represents a playing card with a suit and rank.
///
/// The [CardModel] class represents a single playing card, with properties for the suit, rank, and whether the card is revealed. It provides methods for converting the card to and from JSON, as well as getting the numerical value of the card.
///
/// The [suits] and [ranks] static lists define the valid suits and ranks for a standard deck of playing cards.
class CardModel {
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      suit: json['suit'],
      rank: json['rank'],
      isRevealed: json['isRevealed'] ?? false,
    );
  }
  CardModel({
    required this.suit,
    required this.rank,
    this.partOfSet = false,
    this.isRevealed = false,
  });
  final String suit;
  final String rank;

  /// Indicates whether the card is currently revealed or hidden.
  bool isRevealed = false;

  /// Indicates whether the card is selectable by the user.
  bool isSelectable = false;

  /// Indicates whether the card is part of a set of same Rank for a granting a total of zero points
  bool partOfSet;

  @override
  String toString() {
    return '$rank$suit${isRevealed ? '|' : '_'}';
  }

  Map<String, dynamic> toJson() {
    return {
      'suit': suit,
      'rank': rank,
      'isRevealed': isRevealed ? true : null,
    };
  }

  static const List<String> suits = ['♥️', '♦️', '♣️', '♠️'];
  static const List<String> ranks = [
    'A', // Ace
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'X', // 10
    'J', // Jack
    'Q', // Queen
    'K', // King
    // '§', // Joker are special we ony generate 2 per deck, so do not include them here
  ];

  /// Returns the numerical value of a card rank.
  ///
  /// Handles special cases for 'A', 'X', 'K', 'Q', 'J', '§'
  /// Ranks '2' through '10' return their face value.
  /// Returns 0 if the rank is invalid.
  int get value {
    if (rank == '§') {
      return -2;
    }
    if (rank == 'A') {
      return 1;
    }
    if (rank == 'X') {
      return 10;
    }
    if (rank == 'J') {
      return 11;
    }
    if (rank == 'Q') {
      return 12;
    }
    if (rank == 'K') {
      return 0;
    }

    // face value for cards from 2 to 10
    return int.tryParse(rank) ?? 0;
  }
}
