import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/guess_input.dart';
import '../../widgets/guess_history.dart';
import 'dart:async';
import '../../widgets/animated_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  final bool isPlayer1;
  final int timeLimit;
  final int numDigits;

  GameScreen({required this.gameId, required this.isPlayer1, required this.timeLimit, required this.numDigits});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPlayerTurn = true;
  List<Map<String, dynamic>> _player1History = [];
  List<Map<String, dynamic>> _player2History = [];
  String _player1Name = 'Jugador 1';
  String _player2Name = 'Jugador 2';
  Timer? _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _listenForGameUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _listenForGameUpdates() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          _isPlayerTurn = widget.isPlayer1 ? data['player1Turn'] : data['player2Turn'];
          _player1History = List<Map<String, dynamic>>.from(data['player1History'] ?? []);
          _player2History = List<Map<String, dynamic>>.from(data['player2History'] ?? []);
          _player1Name = data['player1Name'] ?? 'Jugador 1';
          _player2Name = data['player2Name'] ?? 'Jugador 2';

          if (_isPlayerTurn) {
            _startTimer(data['timeLimit']);
          } else {
            _timer?.cancel();
          }

          if (data['state'] == 'game_over') {
            _showGameOverDialog(data['winner']);
          }
        });
      }
    });
  }

  void _startTimer(int timeLimit) {
    if (timeLimit > 0) {
      setState(() {
        _timeLeft = timeLimit;
      });
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _timeLeft--;
        });
        if (_timeLeft <= 0) {
          _timer?.cancel();
          _endTurn(isTimeout: true);
        }
      });
    }
  }

  void _submitGuess() async {
    if (!_isPlayerTurn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Espera tu turno')));
      return;
    }

    String guess = _controller.text;
    if (guess.length != widget.numDigits) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El número debe tener ${widget.numDigits} dígitos')));
      return;
    }

    var data = await FirebaseFirestore.instance.collection('games').doc(widget.gameId).get();
    var opponentNumber = widget.isPlayer1 ? data['num2'] : data['num1'];

    int correctDigits = 0;
    int correctPositions = 0;
    for (int i = 0; i < guess.length; i++) {
      if (opponentNumber.contains(guess[i])) {
        correctDigits++;
      }
      if (opponentNumber[i] == guess[i]) {
        correctPositions++;
      }
    }

    String feedback = "Aciertos: $correctDigits\nPosiciones: $correctPositions";
    var guessRecord = {'guess': guess, 'feedback': feedback};

    if (widget.isPlayer1) {
      _player1History.add(guessRecord);
    } else {
      _player2History.add(guessRecord);
    }

    if (correctPositions == widget.numDigits) {
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'player1History': _player1History,
        'player2History': _player2History,
        'state': 'game_over',
        'winner': widget.isPlayer1 ? _player1Name : _player2Name,
      });
      _showGameOverDialog(widget.isPlayer1 ? _player1Name : _player2Name);
    } else {
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'player1History': _player1History,
        'player2History': _player2History,
        'player1Turn': widget.isPlayer1 ? false : true,
        'player2Turn': widget.isPlayer1 ? true : false,
      });

      setState(() {
        _controller.clear();
        _isPlayerTurn = false;
      });
    }
  }

  void _endTurn({bool isTimeout = false}) async {
    if (!_isPlayerTurn && !isTimeout) {
      return;
    }

    await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
      'player1Turn': widget.isPlayer1 ? false : true,
      'player2Turn': widget.isPlayer1 ? true : false,
    });

    setState(() {
      _controller.clear();
      _isPlayerTurn = false;
    });
  }

  void _showGameOverDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¡Juego Terminado!"),
          content: Text("$winner es el ganador."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                FirebaseFirestore.instance.collection('games').doc(widget.gameId).delete();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isPlayerTurn ? Colors.red[50]! : Colors.green[50]!;

    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Juego en Progreso',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Container(
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Turno de ${_isPlayerTurn ? _player1Name : _player2Name}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (widget.timeLimit > 0 && _isPlayerTurn)
                        Text(
                          'Tiempo: $_timeLeft s',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomContainer(
                    child: Column(
                      children: [
                        if (_isPlayerTurn) GuessInput(controller: _controller, numDigits: widget.numDigits),
                        if (_isPlayerTurn) SizedBox(height: 20),
                        if (_isPlayerTurn)
                          CustomButton(
                            text: 'Intentar',
                            onPressed: _submitGuess,
                            tooltipMessage: 'Enviar intento',
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: CustomContainer(
                      child: Column(
                        children: [
                          Text('Historial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(_player1Name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Expanded(child: GuessHistory(guessHistory: _player1History)),
                                    ],
                                  ),
                                ),
                                VerticalDivider(),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(_player2Name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Expanded(child: GuessHistory(guessHistory: _player2History)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
