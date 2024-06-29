import 'package:flutter/material.dart';

class NumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final int numDigits;

  NumberInputField({required this.controller, required this.numDigits});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Ingrese su número',
        border: OutlineInputBorder(),
      ),
      maxLength: numDigits,
    );
  }
}