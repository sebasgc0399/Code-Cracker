import 'package:flutter/material.dart';
import 'local/local_game_mode_selection_screen.dart';
import 'multijugador/multiplayer_mode_selection_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_container.dart';
import '../widgets/animated_background.dart';
import '../utils/navigation_utils.dart';
import 'settings_screen.dart'; // Importa la nueva pantalla de configuraciones

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/Code_Cracker.png', width: 300), // Ajustar el tamaño del logo
                  SizedBox(height: 20), // Espacio alrededor del logo
                  CustomContainer(
                    child: CustomButton(
                      text: 'Juego Local',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(LocalGameModeSelectionScreen()),
                        );
                      },
                      tooltipMessage: 'En el modo de juego local, el jugador intenta adivinar el número secreto del otro, usando pistas de aciertos de dígitos y posiciones correctas.',
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: CustomButton(
                      text: 'Multijugador',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(MultiplayerModeSelectionScreen()), // Navega a la nueva pantalla
                        );
                      },
                      tooltipMessage: 'Selecciona un modo multijugador para jugar con amigos.',
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: CustomButton(
                      text: 'Configuraciones',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(SettingsScreen()), // Navega a la pantalla de configuraciones
                        );
                      },
                      tooltipMessage: 'Ajusta las configuraciones del juego.',
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
