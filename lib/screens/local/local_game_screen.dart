import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/local_game_info_row.dart';
import '../../widgets/local_history_list.dart';
import '../../widgets/local_number_input_field.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';

class LocalGameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final int timeLimit;
  final int numDigits;

  LocalGameScreen({
    required this.player1Name,
    required this.player2Name,
    required this.timeLimit,
    required this.numDigits,
  });

  @override
  _LocalGameScreenState createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _player1History = [];
  final List<String> _player2History = [];
  String _feedback = "";
  String _player1Number = "";
  String _player2Number = "";
  bool _isPlayer1Turn = true;
  bool _numbersSet = false;
  Timer? _timer;
  int _timeLeft = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timeLeft = widget.timeLimit;
    });
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _endTurn();
        }
      });
    });
  }

  void _setPlayerNumber(String number, bool isPlayer1) {
    setState(() {
      if (isPlayer1) {
        _player1Number = number;
      } else {
        _player2Number = number;
      }
      if (_player1Number.length == widget.numDigits && _player2Number.length == widget.numDigits) {
        _numbersSet = true;
        if (widget.timeLimit > 0) {
          _startTimer();
        }
      }
    });
  }

  void _checkGuess(String guess) {
    String targetNumber = _isPlayer1Turn ? _player2Number : _player1Number;
    int correctDigits = 0;
    int correctPositions = 0;

    for (int i = 0; i < guess.length; i++) {
      if (targetNumber.contains(guess[i])) {
        correctDigits++;
      }
      if (targetNumber[i] == guess[i]) {
        correctPositions++;
      }
    }

    setState(() {
      _feedback = "Aciertos: $correctDigits\nPosiciones: $correctPositions";
      if (_isPlayer1Turn) {
        _player1History.add("$guess\n$_feedback");
      } else {
        _player2History.add("$guess\n$_feedback");
      }

      if (correctPositions == widget.numDigits) {
        _showWinnerDialog(_isPlayer1Turn ? widget.player1Name : widget.player2Name);
      } else {
        _endTurn();
      }
    });
  }

  void _endTurn() {
    setState(() {
      _isPlayer1Turn = !_isPlayer1Turn;
      _controller.clear();
      if (widget.timeLimit > 0) {
        _startTimer();
      }
    });
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Tenemos un ganador!'),
          content: Text('$winner ha ganado el juego.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Reiniciar'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _controller.clear();
      _player1History.clear();
      _player2History.clear();
      _feedback = "";
      _player1Number = "";
      _player2Number = "";
      _isPlayer1Turn = true;
      _numbersSet = false;
      _timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isPlayer1Turn ? Colors.red[50]! : Colors.green[50]!;

    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Juego Local',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Container(
            color: _numbersSet ? backgroundColor : (_player1Number.isEmpty ? Colors.red[50] : Colors.green[50]),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _numbersSet ? _buildGameUI() : _buildSetupUI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupUI() {
    return CustomContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _player1Number.isEmpty ? '${widget.player1Name}: Ingrese su número' : '${widget.player2Name}: Ingrese su número',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          NumberInputField(controller: _controller, numDigits: widget.numDigits),
          SizedBox(height: 20),
          CustomButton(
            text: 'Guardar número',
            onPressed: () {
              if (_controller.text.length == widget.numDigits) {
                _setPlayerNumber(_controller.text, _player1Number.isEmpty);
                _controller.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El número debe tener ${widget.numDigits} dígitos')));
              }
            },
            tooltipMessage: 'Guarda el número ingresado como el número secreto del jugador.',
          ),
        ],
      ),
    );
  }

  Widget _buildGameUI() {
    return Column(
      children: <Widget>[
        GameInfoRow(isPlayer1Turn: _isPlayer1Turn, player1Name: widget.player1Name, player2Name: widget.player2Name, timeLimit: widget.timeLimit, timeLeft: _timeLeft),
        SizedBox(height: 20),
        CustomContainer(
          child: Column(
            children: [
              NumberInputField(controller: _controller, numDigits: widget.numDigits),
              SizedBox(height: 20),
              CustomButton(
                text: 'Intentar',
                onPressed: () {
                  if (_controller.text.length == widget.numDigits) {
                    _checkGuess(_controller.text);
                    _controller.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El intento debe tener ${widget.numDigits} dígitos')));
                  }
                },
                tooltipMessage: 'Realiza un intento para adivinar el número secreto del oponente.',
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
            child: Column(
              children: [
                Text('Historial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(widget.player1Name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            HistoryList(history: _player1History),
                          ],
                        ),
                      ),
                      VerticalDivider(),
                      Expanded(
                        child: Column(
                          children: [
                            Text(widget.player2Name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            HistoryList(history: _player2History),
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
    );
  }
}
