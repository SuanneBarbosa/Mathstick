import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final String tooltip;
  final String semanticsLabel;
  final VoidCallback onTap;

  const MenuButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.tooltip,
    required this.onTap, 
    required this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12), // Tamanho do texto
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
