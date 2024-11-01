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

      gameModel.gameState =
          GameStates.pickCardFromPiles; // Set the state to allow drawing

      // Act
      gameModel.drawCard(mockContext, fromDiscardPile: true);

      // Assert
      expect(
        gameModel.deck.cardsDeckDiscarded.isEmpty,
        true,
        reason: 'Discard pile should be empty',
      );

      expect(
        gameModel.selectedCard,
        isNotNull,
        reason: 'A card should have been picked up',
      );

      expect(
        gameModel.gameState,
        GameStates.flipAndSwap,
        reason: 'State should have changed to flipAndSwap',
      );
    });
  });
}
