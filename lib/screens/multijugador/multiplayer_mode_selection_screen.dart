import 'package:flutter/material.dart';
import '../../widgets/luxury_app_bar.dart';
import 'multiplayer_selection_screen.dart';
import 'multiplayer_settings_screen.dart'; // Asegúrate de importar la pantalla de configuración
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/animated_background.dart';
import '../../utils/navigation_utils.dart';

class MultiplayerModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Selecciona el Modo Multijugador',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomContainer(
                    child: CustomButton(
                      text: '1 VS 1',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(MultiplayerSelectionScreen()),
                        );
                      },
                      tooltipMessage: 'En el modo 1 VS 1, puedes compartir tu ID de partida con un amigo para jugar simultáneamente. Cada jugador intenta adivinar el número secreto del otro, usando pistas de aciertos de dígitos y posiciones correctas.',
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: CustomButton(
                      text: 'Todos VS CPU',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(MultiplayerSettingsScreen(mode: 'cpu')),
                        );
                      },
                      tooltipMessage: 'En el modo Todos VS CPU, varios jugadores intentan adivinar el número secreto de la CPU.',
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: CustomButton(
                      text: 'Todos VS Todos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(MultiplayerSettingsScreen(mode: 'all')),
                        );
                      },
                      tooltipMessage: 'En el modo Todos VS Todos, cada jugador intenta adivinar el número secreto de todos los demás jugadores.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
