import 'package:cards/models/player_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerModel', () {
    late PlayerModel player;

    setUp(() {
      player = PlayerModel(name: 'Test Player');
    });

    test('reset clears hand', () {
      player.hand = [
        CardModel(suit: '♥️', rank: 'A'),
        CardModel(suit: '♦️', rank: '2'),
      ];
      player.reset();
      expect(player.hand, isEmpty);
    });

    test('addCardToHand adds card correctly', () {
      final card = CardModel(suit: '♥️', rank: 'A');
      player.addCardToHand(card);
      expect(player.hand.length, 1);
      expect(player.hand.first, card);
    });

    test('revealInitialCards reveals correct cards', () {
      for (int i = 0; i < 9; i++) {
        player.addCardToHand(CardModel(suit: '♥️', rank: 'A'));
      }
      player.revealInitialCards();
      expect(player.hand[3].isRevealed, true);
      expect(player.hand[5].isRevealed, true);
      expect(player.hand[0].isRevealed, false);
    });

    test('sumOfRevealedCards identifies vertical sets', () {
      player.addCardToHand(CardModel(suit: '♥️', rank: 'Q', isRevealed: true));
      player.addCardToHand(CardModel(suit: '♦️', rank: '2'));
      player.addCardToHand(CardModel(suit: '♣️', rank: '3'));
      player.addCardToHand(CardModel(suit: '♠️', rank: 'Q', isRevealed: true));
      player.addCardToHand(CardModel(suit: '♥️', rank: '5'));
      player.addCardToHand(CardModel(suit: '♦️', rank: '6'));
      player.addCardToHand(CardModel(suit: '♣️', rank: 'Q', isRevealed: true));
      player.addCardToHand(CardModel(suit: '♠️', rank: '8'));
      player.addCardToHand(CardModel(suit: '♥️', rank: '9'));
      expect(player.sumOfRevealedCards, 0);
    });

    test('toJson creates correct json representation', () {
      player.addCardToHand(CardModel(suit: '♥️', rank: 'A', isRevealed: true));
      player.addCardToHand(CardModel(suit: '♦️', rank: '2'));

      final json = player.toJson();

      expect(json['name'], 'Test Player');
      expect(json['hand'], isA<List>());
      expect(json['hand'].length, 2);
      expect(json['hand'][0]['suit'], '♥️');
      expect(json['hand'][0]['rank'], 'A');
      expect(json['hand'][0]['isRevealed'], true);
    });

    test('fromJson creates correct player model', () {
      final json = {
        'name': 'Test Player',
        'hand': [
          {'suit': '♥️', 'rank': 'A', 'isRevealed': true},
          {'suit': '♦️', 'rank': '2'},
        ],
      };

      final playerFromJson = PlayerModel.fromJson(json);

      expect(playerFromJson.name, 'Test Player');
      expect(playerFromJson.hand.length, 2);
      expect(playerFromJson.hand[0].suit, '♥️');
      expect(playerFromJson.hand[0].rank, 'A');
      expect(playerFromJson.hand[0].isRevealed, true);
    });
  });
}
