import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/luxury_app_bar.dart';
import '../../widgets/animated_background.dart';

class MultiplayerWaitingScreen extends StatefulWidget {
  final String gameId;
  final bool isPlayer1;
  final Widget Function(String gameId, bool isPlayer1) createGameScreen;

  MultiplayerWaitingScreen({
    required this.gameId,
    required this.isPlayer1,
    required this.createGameScreen,
  });

  @override
  _MultiplayerWaitingScreenState createState() => _MultiplayerWaitingScreenState();
}

class _MultiplayerWaitingScreenState extends State<MultiplayerWaitingScreen> {
  @override
  void initState() {
    super.initState();
    _listenForGameUpdates();
  }

  void _listenForGameUpdates() {
    FirebaseFirestore.instance.collection('games').doc(widget.gameId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;
        if (data['state'] == 'joined') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.createGameScreen(widget.gameId, widget.isPlayer1),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Esperando Jugador',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: CustomContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Esperando a que otro jugador se una...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (widget.isPlayer1) // Mostrar opción de copiar ID solo para el jugador 1
                    Column(
                      children: [
                        Text(
                          'ID de la partida:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: widget.gameId),
                                readOnly: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: widget.gameId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('ID copiado al portapapeles')),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Copia este ID y compártelo con tu amigo para que se una a la partida.',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
