import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_container.dart';
import '../widgets/luxury_app_bar.dart';
import '../widgets/animated_background.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Configuraciones',
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
                    Text('Configuración de Sonido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    CustomButton(
                      text: 'Volumen de Música',
                      onPressed: () {
                        // Implementar la funcionalidad para ajustar el volumen de la música
                      },
                      tooltipMessage: 'Ajustar el volumen de la música',
                    ),
                    SizedBox(height: 10),
                    CustomButton(
                      text: 'Volumen de Efectos',
                      onPressed: () {
                        // Implementar la funcionalidad para ajustar el volumen de los efectos
                      },
                      tooltipMessage: 'Ajustar el volumen de los efectos',
                    ),
                    SizedBox(height: 20),
                    Text('Idioma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    CustomButton(
                      text: 'Seleccionar Idioma',
                      onPressed: () {
                        // Implementar la funcionalidad para seleccionar el idioma
                      },
                      tooltipMessage: 'Seleccionar el idioma del juego',
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
