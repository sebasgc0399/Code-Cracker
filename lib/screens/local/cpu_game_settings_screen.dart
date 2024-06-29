import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';
import '../../utils/navigation_utils.dart';
import 'cpu_game_screen.dart';

class CpuGameSettingsScreen extends StatefulWidget {
  @override
  _CpuGameSettingsScreenState createState() => _CpuGameSettingsScreenState();
}

class _CpuGameSettingsScreenState extends State<CpuGameSettingsScreen> {
  int _numDigits = 4;

  void _startGame(BuildContext context) {
    Navigator.push(
      context,
      createRoute(CpuGameScreen(numDigits: _numDigits)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Configuración 1 vs CPU',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: CustomContainer(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Número de dígitos:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 40),
                  CustomButton(
                    text: 'Iniciar Juego',
                    onPressed: () {
                      _startGame(context);
                    },
                    tooltipMessage: 'Comienza el juego contra la CPU con el número de dígitos seleccionado.',
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
