import 'package:cards/models/game_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create a mock BuildContext - necessary for methods that use BuildContext
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('GameModel', () {
    late GameModel gameModel;
    late MockBuildContext mockContext; // Instance of the mock

    setUp(() {
      mockContext = MockBuildContext();
      gameModel = GameModel(
        loginUserName: 'Player 1',
        names: ['Player 1', 'Player 2'],
        gameRoomId: 'testRoom',
        isNewGame: true,
      );
    });

    test('drawCard from discard pile updates game state', () {
      // On start up 18 cards were distributed to the players, and the first card of the deck is flipped in the discarded pile.
      expect(
        gameModel.deck.cardsDeckDiscarded.length,
        1,
        reason: 'Discard pile should have 1 card in it',
      );

      // Set the state enable select a card from either pile
      gameModel.gameState = GameStates.pickCardFromEitherPiles;

      // Action user picked the top card of the discarded pile
      gameModel.selectTopCardOfDeck(mockContext, fromDiscardPile: true);

      expect(
        gameModel.gameState,
        GameStates.swapDiscardedCardWithAnyCardsInHand,
        reason: 'State should have changed to flipAndSwap',
      );
    });
  });
}
