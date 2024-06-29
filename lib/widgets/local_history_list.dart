import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;

  HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}