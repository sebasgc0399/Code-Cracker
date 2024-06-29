import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/guess_input.dart';
import '../../widgets/guess_history.dart';
import 'dart:async';
import 'dart:math';
import '../../widgets/animated_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';

class MultiplayerGameScreenCPU extends StatefulWidget {
  final String gameId;
  final int timeLimit;
  final int numDigits;

  MultiplayerGameScreenCPU({
    required this.gameId,
    required this.timeLimit,
    required this.numDigits,
  });

  @override
  _MultiplayerGameScreenCPUState createState() => _MultiplayerGameScreenCPUState();
}

class _MultiplayerGameScreenCPUState extends State<MultiplayerGameScreenCPU> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _sharedHistory = [];
  String _cpuNumber = '';
  Timer? _timer;
  int _timeLeft = 0;
  List<String> players = [];
  int currentPlayerIndex = 0;
  bool _isPlayerTurn = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _listenForGameUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() async {
    var gameDoc = await FirebaseFirestore.instance.collection('games').doc(widget.gameId).get();
    var data = gameDoc.data();
    setState(() {
      players = List<String>.from(data!['players']);
      _cpuNumber = _generateRandomNumber(widget.numDigits);
      _updatePlayerTurn(data['currentPlayerIndex'] ?? 0); // Inicializa el turno
    });
  }

  void _listenForGameUpdates() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          _sharedHistory = List<Map<String, dynamic>>.from(data['sharedHistory'] ?? []);
          currentPlayerIndex = data['currentPlayerIndex'];
          _isPlayerTurn = players[currentPlayerIndex] == players[currentPlayerIndex];

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
          _submitGuess(isTimeout: true);
        }
      });
    }
  }

  String _generateRandomNumber(int length) {
    final random = Random();
    String number = '';
    for (int i = 0; i < length; i++) {
      number += random.nextInt(10).toString();
    }
    return number;
  }

  void _submitGuess({bool isTimeout = false}) async {
    if (!_isPlayerTurn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Espera tu turno')));
      return;
    }

    String guess = _controller.text;
    if (!isTimeout && guess.length != widget.numDigits) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El número debe tener ${widget.numDigits} dígitos')));
      return;
    }

    if (isTimeout) {
      guess = List.generate(widget.numDigits, (index) => '0').join();
    }

    int correctDigits = 0;
    int correctPositions = 0;
    for (int i = 0; i < guess.length; i++) {
      if (_cpuNumber.contains(guess[i])) {
        correctDigits++;
      }
      if (_cpuNumber[i] == guess[i]) {
        correctPositions++;
      }
    }

    String feedback = "Aciertos: $correctDigits\nPosiciones: $correctPositions";
    var guessRecord = {'guess': guess, 'feedback': feedback, 'player': players[currentPlayerIndex]};

    _sharedHistory.add(guessRecord);

    if (correctPositions == widget.numDigits) {
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'sharedHistory': _sharedHistory,
        'state': 'game_over',
        'winner': players[currentPlayerIndex],
      });
      _showGameOverDialog(players[currentPlayerIndex]);
    } else {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'sharedHistory': _sharedHistory,
        'currentPlayerIndex': currentPlayerIndex,
      });

      setState(() {
        _controller.clear();
        _isPlayerTurn = false;
      });
    }
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

  void _updatePlayerTurn(int index) {
    setState(() {
      currentPlayerIndex = index;
      _isPlayerTurn = players[currentPlayerIndex] == players[currentPlayerIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Turno de ${players[currentPlayerIndex]}',
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
                            child: GuessHistory(guessHistory: _sharedHistory),
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
