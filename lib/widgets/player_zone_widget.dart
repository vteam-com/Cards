import 'dart:math';
import 'package:cards/models/game_model.dart';
import 'package:cards/widgets/card_widget.dart';
import 'package:cards/widgets/player_header_widget.dart';
import 'package:cards/widgets/player_zone_cta_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneWidget extends StatefulWidget {
  const PlayerZoneWidget({
    super.key,
    required this.gameModel,
    required this.player,
    required this.smallDevice,
  });
  final GameModel gameModel;
  final PlayerModel player;
  final bool smallDevice;

  @override
  State<PlayerZoneWidget> createState() => _PlayerZoneWidgetState();
}

class _PlayerZoneWidgetState extends State<PlayerZoneWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      width: min(400, MediaQuery.of(context).size.width),
      padding: EdgeInsets.all(widget.smallDevice ? 8 : 20),
      decoration: BoxDecoration(
        color: Colors.green.shade800.withAlpha(100),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color:
              widget.player.isActivePlayer ? Colors.yellow : Colors.transparent,
          width: widget.player.isActivePlayer ? 4.0 : 12.0,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //
            // Header
            //
            PlayerHeaderWidget(
              name: widget.player.name,
              sumOfRevealedCards: widget.player.sumOfRevealedCards,
            ),
            Divider(
              color: Colors.white.withAlpha(100),
            ),

            //
            // CTA
            //
            PlayerZoneCtaWidget(
              player: widget.player,
              gameModel: widget.gameModel,
            ),
            Divider(
              color: Colors.white.withAlpha(100),
            ),

            //
            // Cards in Hand
            //
            SizedBox(
              height: widget.smallDevice ? 380 : null,
              child: FittedBox(
                fit: BoxFit.cover,
                child: buildPlayerHand(
                  context,
                  widget.gameModel,
                  widget.player,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient activeBorder() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.yellow.shade200,
        Colors.yellow.shade700,
      ],
    );
  }

  Widget buildPlayerHand(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [0, 1, 2].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
            Row(
              children: [3, 4, 5].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
            Row(
              children: [6, 7, 8].map(
                (cardIndex) {
                  return buildPlayerCardButton(
                    context,
                    gameModel,
                    player,
                    cardIndex,
                  );
                },
              ).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget buildPlayerCardButton(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
    int gridIndex,
  ) {
    final CardModel card = player.hand[gridIndex];

    card.isRevealed = player.hand[gridIndex].isRevealed;

    card.isSelectable = player.isActivePlayer &&
        (gameModel.gameState ==
                GameStates.swapDiscardedCardWithAnyCardsInHand ||
            gameModel.gameState ==
                GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
            (gameModel.gameState == GameStates.revealOneHiddenCard &&
                !card.isRevealed));

    return GestureDetector(
      onTap: () {
        gameModel.revealCard(context, player, gridIndex);
      },
      child: CardWidget(card: card),
    );
  }
}
