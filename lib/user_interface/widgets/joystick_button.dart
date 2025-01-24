import 'package:flutter/material.dart';

class JoystickButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final String semanticsLabel;

  const JoystickButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
       final double buttonSize = (screenWidth * 0.1).clamp(40.0, 80.0);
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // shape: const CircleBorder(),
            // padding: const EdgeInsets.all(20),
            backgroundColor: Colors.blue.withOpacity(0.8),
          ),
          onPressed: onPressed,
          child: Icon(
            icon, 
            color: Colors.white,
            size: buttonSize * 0.5,),
         
        ),
      ),
    );
  }
}
