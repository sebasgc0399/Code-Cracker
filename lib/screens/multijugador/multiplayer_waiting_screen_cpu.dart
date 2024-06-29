import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';

class MultiplayerWaitingScreenCPU extends StatefulWidget {
  final String gameId;
  final Widget Function(String gameId) createGameScreen;

  MultiplayerWaitingScreenCPU({
    required this.gameId,
    required this.createGameScreen,
  });

  @override
  _MultiplayerWaitingScreenCPUState createState() => _MultiplayerWaitingScreenCPUState();
}

class _MultiplayerWaitingScreenCPUState extends State<MultiplayerWaitingScreenCPU> {
  List<String> players = [];
  String creator = '';

  @override
  void initState() {
    super.initState();
    _listenForGameUpdates();
  }

  void _listenForGameUpdates() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          players = List<String>.from(data['players'] ?? []);
          creator = data['creator'];
        });
        if (data['state'] == 'ready') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.createGameScreen(widget.gameId),
            ),
          );
        }
      }
    });
  }

  void _startGame() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
      'state': 'ready',
      'currentPlayerIndex': 0, // Iniciar con el primer jugador
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentPlayer = players.isNotEmpty ? players[0] : '';

    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Esperando Jugadores',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: CustomContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Esperando a que otros jugadores se unan...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        'ID de la partida:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: widget.gameId),
                              readOnly: true,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.gameId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ID copiado al portapapeles')),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Copia este ID y compártelo con tus amigos para que se unan a la partida.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      if (players.length > 1 && currentPlayer == creator)
                        CustomButton(
                          text: 'Iniciar Juego',
                          onPressed: _startGame,
                          tooltipMessage: 'Iniciar el juego cuando todos los jugadores se hayan unido.',
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Jugadores:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ...players.map((player) => Text(player)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
