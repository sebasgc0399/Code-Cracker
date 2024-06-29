import 'package:flutter/material.dart';

class LuxuryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;

  const LuxuryAppBar({required this.title, required this.onBackPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.amber),
            onPressed: onBackPressed,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[900], // Fondo elegante
      elevation: 10, // Elevación para dar un efecto de sombra
      shadowColor: Colors.black.withOpacity(0.5), // Color de la sombra
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
