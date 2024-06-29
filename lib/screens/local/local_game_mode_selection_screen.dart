import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/animated_background.dart';
import '../../utils/navigation_utils.dart'; 
import '../../widgets/luxury_app_bar.dart';
import 'cpu_game_settings_screen.dart';
import 'local_game_settings_screen.dart';

class LocalGameModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Selecciona el Modo de Juego Local',
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
                          createRoute(LocalGameSettingsScreen()), // Utiliza la navegación con animación
                        );
                      },
                      tooltipMessage: 'En el modo 1 VS 1, dos jugadores intentan adivinar el número secreto del otro desde el mismo dispositivo. Usa pistas de aciertos de dígitos y posiciones correctas para ganar.',
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: CustomButton(
                      text: '1 VS CPU',
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(CpuGameSettingsScreen()), // Utiliza la navegación con animación
                        );
                      },
                      tooltipMessage: 'En el modo 1 VS CPU, el jugador intenta adivinar un número secreto generado aleatoriamente por la computadora. Usa pistas de aciertos de dígitos y posiciones correctas para ganar.',
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
