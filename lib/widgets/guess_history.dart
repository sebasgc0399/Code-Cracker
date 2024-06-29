import 'package:flutter/material.dart';

class GuessHistory extends StatelessWidget {
  final List<Map<String, dynamic>> guessHistory;

  GuessHistory({required this.guessHistory});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: guessHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(guessHistory[index]['guess']),
          subtitle: Text(guessHistory[index]['feedback']),
        );
      },
    );
  }
}
