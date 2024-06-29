import 'package:flutter/material.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../utils/navigation_utils.dart';
import 'local_game_screen.dart';

class LocalGameSettingsScreen extends StatefulWidget {
  @override
  _LocalGameSettingsScreenState createState() => _LocalGameSettingsScreenState();
}

class _LocalGameSettingsScreenState extends State<LocalGameSettingsScreen> {
  final TextEditingController _player1NameController = TextEditingController();
  final TextEditingController _player2NameController = TextEditingController();
  int _selectedTimeLimit = 0;
  int _numDigits = 4;

  void _startGame() {
    String player1Name = _player1NameController.text.isEmpty ? 'Jugador 1' : _player1NameController.text;
    String player2Name = _player2NameController.text.isEmpty ? 'Jugador 2' : _player2NameController.text;

    Navigator.push(
      context,
      createRoute(LocalGameScreen(
        player1Name: player1Name,
        player2Name: player2Name,
        timeLimit: _selectedTimeLimit,
        numDigits: _numDigits,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Configuración del Juego Local',
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
                      controller: _player1NameController,
                      decoration: InputDecoration(labelText: 'Nombre del Jugador 1'),
                    ),
                    TextField(
                      controller: _player2NameController,
                      decoration: InputDecoration(labelText: 'Nombre del Jugador 2'),
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
                        text: 'Iniciar Juego',
                        onPressed: _startGame,
                        tooltipMessage: 'Inicia el juego con la configuración seleccionada.',
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
