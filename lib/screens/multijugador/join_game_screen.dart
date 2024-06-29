import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';
import '../../utils/navigation_utils.dart';
import 'multiplayer_game_screen_cpu.dart';
import 'multiplayer_waiting_screen.dart';
import 'multiplayer_waiting_screen_cpu.dart';

class JoinGameScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController playerNameController;
  final int selectedTimeLimit;
  final int numDigits;
  final Widget Function(String gameId, bool isPlayer1) createGameScreen; // Callback para crear la pantalla del juego

  JoinGameScreen({
    required this.playerNameController,
    required this.selectedTimeLimit,
    required this.numDigits,
    required this.createGameScreen, // Acepta el callback como argumento
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Unirse a Partida',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: CustomContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(labelText: 'ID de la Partida'),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        text: 'Unirse',
                        onPressed: () {
                          _joinGame(context, _controller.text);
                        },
                        tooltipMessage: 'Unirse a una partida existente utilizando un ID.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _joinGame(BuildContext context, String gameId) async {
    var gameDoc = await FirebaseFirestore.instance.collection('games').doc(gameId).get();
    if (gameDoc.exists) {
      var data = gameDoc.data()!;
      List<String> players = List<String>.from(data['players'] ?? []);
      if (players.length < 10) {
        players.add(playerNameController.text.isEmpty ? 'Jugador ${players.length + 1}' : playerNameController.text);

        await FirebaseFirestore.instance.collection('games').doc(gameId).update({
          'players': players,
        });

        Navigator.pushReplacement(
          context,
          createRoute(
            data['mode'] == 'cpu'
                ? MultiplayerWaitingScreenCPU(
                    gameId: gameId,
                    createGameScreen: (gameId) => MultiplayerGameScreenCPU(
                      gameId: gameId,
                      timeLimit: selectedTimeLimit,
                      numDigits: numDigits,
                    ),
                  )
                : MultiplayerWaitingScreen(
                    gameId: gameId,
                    isPlayer1: false,
                    createGameScreen: createGameScreen, // Usa el callback proporcionado
                  ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La partida está llena')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID de la Partida no válido')),
      );
    }
  }
}
