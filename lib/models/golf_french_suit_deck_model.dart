import 'package:cards/models/french_suit_card_model.dart';
import 'package:cards/models/game_model.dart';
import 'package:cards/models/golf_french_suit_card_model.dart';
export 'package:cards/models/card_model.dart';

class GolfFrenchSuitDeckModel extends DeckModel {
  GolfFrenchSuitDeckModel(super.numberOfDecks) : super();

  factory GolfFrenchSuitDeckModel.fromJson(Map<String, dynamic> json) {
    return GolfFrenchSuitDeckModel(json['numberOfDecks'] ?? 1)
      ..cardsDeckPile = List<GolfFrenchSuitCardModel>.from(
        json['cardsDeckPile']
                ?.map((card) => GolfFrenchSuitCardModel.fromJson(card)) ??
            [],
      )
      ..cardsDeckDiscarded = List<GolfFrenchSuitCardModel>.from(
        json['cardsDeckDiscarded']
                ?.map((card) => GolfFrenchSuitCardModel.fromJson(card)) ??
            [],
      );
  }

  @override
  void addCardsToDeck() {
    for (String suit in FrenchSuitCardModel.suits) {
      for (String rank in FrenchSuitCardModel.ranks) {
        cardsDeckPile.add(
          FrenchSuitCardModel(
            suit: suit,
            rank: rank,
          ),
        );
      }
    }
    // Add 2 Jokers to each deck
    cardsDeckPile.addAll([
      CardModel(suit: '*', rank: '§'),
      CardModel(suit: '*', rank: '§'),
    ]);
  }
}
