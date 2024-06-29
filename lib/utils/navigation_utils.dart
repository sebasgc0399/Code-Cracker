import 'package:flutter/material.dart';

Route createRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Define el punto de inicio de la animación (fuera de la pantalla a la derecha)
      const end = Offset.zero; // Define el punto de finalización de la animación (en su posición original)
      const curve = Curves.ease; // Define la curva de animación

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child); // Usa SlideTransition para la animación
    },
  );
}
