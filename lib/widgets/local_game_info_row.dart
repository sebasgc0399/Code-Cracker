import 'package:flutter/material.dart';

class GameInfoRow extends StatelessWidget {
  final bool isPlayer1Turn;
  final String player1Name;
  final String player2Name;
  final int timeLimit;
  final int timeLeft;

  GameInfoRow({
    required this.isPlayer1Turn,
    required this.player1Name,
    required this.player2Name,
    required this.timeLimit,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isPlayer1Turn ? 'Turno de $player1Name' : 'Turno de $player2Name',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (timeLimit > 0)
          Text(
            'Tiempo: $timeLeft',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}