import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String tooltipMessage;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.tooltipMessage,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onPressed();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[700], // Color de fondo del botón
            foregroundColor: Colors.white, // Color del texto del botón
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadowColor: Colors.black.withOpacity(0.2), // Color de la sombra
            elevation: 10, // Elevación de la sombra
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.text),
              SizedBox(width: 10),
              Tooltip(
                message: widget.tooltipMessage,
                child: Icon(Icons.help_outline, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
