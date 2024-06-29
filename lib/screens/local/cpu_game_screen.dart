import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';

class CpuGameScreen extends StatefulWidget {
  final int numDigits;

  CpuGameScreen({required this.numDigits});

  @override
  _CpuGameScreenState createState() => _CpuGameScreenState();
}

class _CpuGameScreenState extends State<CpuGameScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  String _secretNumber = '';
  String _feedback = "";

  @override
  void initState() {
    super.initState();
    _generateSecretNumber();
  }

  void _generateSecretNumber() {
    final random = Random();
    _secretNumber = List.generate(widget.numDigits, (_) => random.nextInt(10).toString()).join();
  }

  void _submitGuess() {
    String guess = _controller.text;
    if (guess.length != widget.numDigits) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El número debe tener ${widget.numDigits} dígitos')));
      return;
    }

    int correctDigits = 0;
    int correctPositions = 0;
    for (int i = 0; i < guess.length; i++) {
      if (_secretNumber.contains(guess[i])) {
        correctDigits++;
      }
      if (_secretNumber[i] == guess[i]) {
        correctPositions++;
      }
    }

    String feedback = "Aciertos: $correctDigits\nPosiciones: $correctPositions";
    var guessRecord = {'guess': guess, 'feedback': feedback};
    setState(() {
      _history.add(guessRecord);
      _controller.clear();
    });

    if (correctPositions == widget.numDigits) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¡Juego Terminado!"),
          content: Text("¡Has adivinado el número secreto!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
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
        title: 'Juego 1 vs CPU',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                CustomContainer(
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Ingrese su intento',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: widget.numDigits,
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                        text: 'Intentar',
                        onPressed: _submitGuess,
                        tooltipMessage: 'Realiza un intento para adivinar el número secreto generado por la CPU.',
                      ),
                      SizedBox(height: 20),
                      Text(
                        _feedback,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: CustomContainer(
                    child: _buildHistory(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_history[index]['guess'], style: TextStyle(color: Colors.black)),
          subtitle: Text(_history[index]['feedback'], style: TextStyle(color: Colors.black)),
        );
      },
    );
  }
}
