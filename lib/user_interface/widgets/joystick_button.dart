import 'package:flutter/material.dart';

class JoystickButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final String semanticsLabel;

  const JoystickButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.tooltip,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = (screenWidth * 0.08).clamp(5.0, 80.0);

    return Tooltip( 
      message: tooltip,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(2), 
          backgroundColor: Colors.blue.withOpacity(0.8),
        ),
        onPressed: onPressed,
        
        child: Semantics( 
           label: semanticsLabel,
           child:  Icon(
              icon,
              color: Colors.white,
              size: buttonSize * 0.5,
           ),
        )
      ),
    );
  }
}
