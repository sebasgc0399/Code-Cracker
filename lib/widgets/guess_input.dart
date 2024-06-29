import 'package:flutter/material.dart';

class GuessInput extends StatelessWidget {
  final TextEditingController controller;
  final int numDigits;

  GuessInput({required this.controller, required this.numDigits});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Ingrese su intento',
        errorText: controller.text.length != numDigits ? 'Debe ingresar $numDigits dígitos' : null,
        border: OutlineInputBorder(),
      ),
      maxLength: numDigits, // Limita la entrada al número de dígitos
    );
  }
}
