import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_screen.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../utils/navigation_utils.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String gameId;
  final bool isPlayer1;

  MultiplayerGameScreen({required this.gameId, required this.isPlayer1});

  @override
  _MultiplayerGameScreenState createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _hasSubmittedNumber = false;
  int _numDigits = 4; // Default value, it will be updated from Firestore

  @override
  void initState() {
    super.initState();
    _checkPlayerStatus();
  }

  void _checkPlayerStatus() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          _numDigits = data['numDigits'] ?? 4;
          if (widget.isPlayer1) {
            _hasSubmittedNumber = data['player1'] == 'ready';
          } else {
            _hasSubmittedNumber = data['player2'] == 'ready';
          }
        });

        if (data['player1'] == 'ready' && data['player2'] == 'ready' && data['state'] == 'joined') {
          FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
            'state': 'ready',
            'player1Turn': true, // Inicializa el turno del jugador 1
            'player2Turn': false, // Inicializa el turno del jugador 2
          });
        }

        if (data['state'] == 'ready') {
          Navigator.pushReplacement(
            context,
            createRoute(GameScreen(
              gameId: widget.gameId,
              isPlayer1: widget.isPlayer1,
              timeLimit: data['timeLimit'],
              numDigits: data['numDigits'],
            )),
          );
        }
      }
    });
  }

  void _submitNumber() async {
    String numField = widget.isPlayer1 ? 'num1' : 'num2';
    String playerField = widget.isPlayer1 ? 'player1' : 'player2';

    await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
      numField: _controller.text,
      playerField: 'ready',
    });

    setState(() {
      _hasSubmittedNumber = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Esperando a que el otro jugador ingrese su número secreto...',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: _hasSubmittedNumber
                ? Text('Esperando a que el otro jugador ingrese su número secreto...')
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _controller,
                            decoration: InputDecoration(labelText: 'Ingresa tu número secreto'),
                            maxLength: _numDigits,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20),
                          CustomButton(
                            text: 'Enviar',
                            onPressed: _submitNumber,
                            tooltipMessage: 'Enviar número secreto',
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
