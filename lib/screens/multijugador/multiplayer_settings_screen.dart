import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Importa el paquete Clipboard
import 'join_game_screen.dart';
import 'multiplayer_game_screen_cpu.dart';
import 'multiplayer_waiting_screen.dart';
import 'multiplayer_waiting_screen_cpu.dart'; // Nueva pantalla de espera para el modo CPU
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';
import '../../utils/navigation_utils.dart';
import 'multiplayer_game_screen.dart';

class MultiplayerSettingsScreen extends StatefulWidget {
  final String mode;

  MultiplayerSettingsScreen({required this.mode});

  @override
  _MultiplayerSettingsScreenState createState() => _MultiplayerSettingsScreenState();
}

class _MultiplayerSettingsScreenState extends State<MultiplayerSettingsScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  int _selectedTimeLimit = 0;
  int _numDigits = 4;

  void _createGame(BuildContext context) async {
    String playerName = _playerNameController.text.isEmpty ? 'Jugador 1' : _playerNameController.text;
    
    var newGame = await FirebaseFirestore.instance.collection('games').add({
      'players': [playerName],
      'state': 'waiting',
      'timeLimit': _selectedTimeLimit,
      'numDigits': _numDigits,
      'mode': widget.mode,
      'creator': playerName,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Partida Creada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID de la partida:'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: newGame.id),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: newGame.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ID copiado al portapapeles')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Copia este ID y compártelo con tus amigos para que se unan a la partida.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  createRoute(
                    widget.mode == 'cpu'
                        ? MultiplayerWaitingScreenCPU(
                            gameId: newGame.id,
                            createGameScreen: (gameId) => MultiplayerGameScreenCPU(
                              gameId: gameId,
                              timeLimit: _selectedTimeLimit,
                              numDigits: _numDigits,
                            ),
                          )
                        : MultiplayerWaitingScreen(
                            gameId: newGame.id,
                            isPlayer1: true,
                            createGameScreen: (gameId, isPlayer1) => MultiplayerGameScreen(
                              gameId: gameId,
                              isPlayer1: isPlayer1,
                            ),
                          ),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Configuración Multijugador',
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
                      controller: _playerNameController,
                      decoration: InputDecoration(labelText: 'Nombre del Jugador (Opcional)'),
                    ),
                    SizedBox(height: 20),
                    Text('Tiempo por turno:'),
                    DropdownButton<int>(
                      value: _selectedTimeLimit,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedTimeLimit = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 0, child: Text('Sin tiempo')),
                        DropdownMenuItem(value: 30, child: Text('30 segundos')),
                        DropdownMenuItem(value: 60, child: Text('1 minuto')),
                        DropdownMenuItem(value: 90, child: Text('1 minuto y 30 segundos')),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('Número de dígitos:'),
                    DropdownButton<int>(
                      value: _numDigits,
                      onChanged: (int? newValue) {
                        setState(() {
                          _numDigits = newValue!;
                        });
                      },
                      items: [3, 4, 5, 6].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value dígitos'),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        text: 'Crear Partida',
                        onPressed: () {
                          _createGame(context);
                        },
                        tooltipMessage: 'Crear una nueva partida y obtener un ID para compartir.',
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        text: 'Unirse a Partida',
                        onPressed: () {
                          Navigator.push(
                            context,
                            createRoute(JoinGameScreen(
                              playerNameController: _playerNameController,
                              selectedTimeLimit: _selectedTimeLimit,
                              numDigits: _numDigits,
                              createGameScreen: (gameId, isPlayer1) => MultiplayerGameScreen(
                                gameId: gameId,
                                isPlayer1: isPlayer1,
                              ),
                            )),
                          );
                        },
                        tooltipMessage: 'Unirse a una partida existente con un ID.',
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
}
