import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/cards/card_face_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card's face or back.
///
/// The [SkyjoCardFaceWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses different methods to display the front and back of the card depending on its properties.
class SkyjoCardFaceWidget extends CardFaceWidget {
  /// Creates a [SkyjoCardFaceWidget] with a [CardModel] card.
  const SkyjoCardFaceWidget({
    super.key,
    required super.card,
  });

  @override
  Widget build(BuildContext context) {
    return card.isRevealed ? buildFaceUp() : buildFaceDown();
  }

  @override
  Widget buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Container(
            color: getBackColor(card.value),
            child: Column(
              children: [
                buildValue(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildValue() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            card.value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget figureCards(final String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: getSuitColor(card.suit),
            fontSize: 60,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  /// Returns the color associated with the suit string.
  Color getBackColor(int value) {
    if (value < 0) {
      return Colors.blueGrey;
    } else if (value == 0) {
      return Colors.blue;
    } else if (value < 5) {
      return Colors.lightGreen;
    } else if (value < 9) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
