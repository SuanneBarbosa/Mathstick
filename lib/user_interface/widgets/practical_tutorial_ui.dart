import 'package:flutter/material.dart';
import 'package:mathsticks/user_interface/screens/practical_tutorial_screen.dart';
import 'package:mathsticks/user_interface/widgets/grid_painter.dart';
import 'package:mathsticks/user_interface/widgets/joystick_button.dart';
import 'package:mathsticks/user_interface/widgets/menu_button.dart';
import 'package:provider/provider.dart';
import '../../../services/character_service.dart';
import '../../../services/palito_service.dart';

class PracticalTutorialUI extends StatelessWidget {
  final GlobalKey keyPalitoV;
  final GlobalKey keyPalitoH;
  final GlobalKey keyPalitoDD;
  final GlobalKey keyPalitoDE;
  final GlobalKey keyJumpUp;
  final GlobalKey keyJumpDown;
  final GlobalKey keyJumpLeft;
  final GlobalKey keyJumpRight;
  final GlobalKey keyAutoJumpToggle;
  final GlobalKey activeStepKey;
  final VoidCallback onPalitoVTapped;
  final VoidCallback onPalitoHTapped;
  final VoidCallback onPalitoDDTapped;
  final VoidCallback onPalitoDETapped;
  final VoidCallback onJumpUp;
  final VoidCallback onJumpDown;
  final VoidCallback onJumpLeft;
  final VoidCallback onJumpRight;
  final bool isAutoJumpEnabled;
  final ValueChanged<bool> onAutoJumpToggled;
  final TutorialPhase currentPhase;

  const PracticalTutorialUI({
    super.key,
    required this.keyPalitoV,
    required this.keyPalitoH,
    required this.keyPalitoDD,
    required this.keyPalitoDE,
    required this.keyJumpUp,
    required this.keyJumpDown,
    required this.keyJumpLeft,
    required this.keyJumpRight,
    required this.keyAutoJumpToggle,
    required this.onPalitoVTapped,
    required this.onPalitoHTapped,
    required this.onPalitoDDTapped,
    required this.onPalitoDETapped,
    required this.onJumpUp,
    required this.onJumpDown,
    required this.onJumpLeft,
    required this.onJumpRight,
    required this.isAutoJumpEnabled,
    required this.onAutoJumpToggled,
    required this.currentPhase,
    required this.activeStepKey,
  });

  @override
  Widget build(BuildContext context) {
    final characterCtrl = Provider.of<CharacterController>(context);
    // ignore: unused_local_variable
    final palitoCtrl = Provider.of<PalitoController>(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(
              numColumns: (w / characterCtrl.characterSize).floor(),
              numRows: (h / characterCtrl.characterSize).floor(),
              cellSize: characterCtrl.characterSize,
            ),
          ),
        ),
        Consumer<PalitoController>(
          builder: (_, palitoCtrl, __) {
            return Stack(
              children: palitoCtrl.palitos.map((palito) {
                return Positioned(
                  top: palito.position.dy,
                  left: palito.position.dx,
                  child: Image.asset(
                    'assets/images/${palito.type}.png',
                    height: palito.size,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                );
              }).toList(),
            );
          },
        ),
        Positioned(
          left: characterCtrl.xPosition,
          top: characterCtrl.yPosition,
          child: Image.asset(
            'assets/images/personagem.png',
            height: characterCtrl.characterSize,
            width: characterCtrl.characterSize,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            children: [
              MenuButton(
                key: keyPalitoV,
                iconPath: 'assets/images/palito_v.png',
                label: "Palito V",
                tooltip: "Palito Vertical",
                semanticsLabel: "Adicionar Palito Vertical",
                onTap: activeStepKey == keyPalitoV ? onPalitoVTapped : () {},
                iconSize: characterCtrl.characterSize,
              ),
              MenuButton(
                key: keyPalitoDD,
                iconPath: 'assets/images/palito_dd.png',
                label: 'Palito DD',
                tooltip: 'Palito Diagonal à Direita',
                semanticsLabel: ' Adicionar Palito Diagonal à Direita',
                onTap: activeStepKey == keyPalitoDD ? onPalitoDDTapped : () {},
              ),
              MenuButton(
                key: keyPalitoDE,
                iconPath: 'assets/images/palito_de.png',
                label: 'Palito DE',
                tooltip: 'Palito Diagonal à Esquerda',
                semanticsLabel: 'Adicionar Palito Diagonal à Esquerda',
                onTap: activeStepKey == keyPalitoDE ? onPalitoDETapped : () {},
              ),
              const SizedBox(height: 8),
              MenuButton(
                key: keyPalitoH,
                iconPath: 'assets/images/palito_h.png',
                label: "Palito H",
                tooltip: "Palito Horizontal",
                semanticsLabel: "Adicionar Palito Horizontal",
                onTap: activeStepKey == keyPalitoH ? onPalitoHTapped : () {},
                iconSize: characterCtrl.characterSize,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: 16,
          child: Row(
            children: [
              JoystickButton(
                key: keyJumpLeft,
                icon: Icons.arrow_left,
                tooltip: 'Saltar para Esquerda',
                semanticsLabel: 'Saltar para Esquerda',
                onPressed: activeStepKey == keyJumpLeft ? onJumpLeft : null,
              ),
              const SizedBox(width: 1),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JoystickButton(
                    key: keyJumpUp,
                    icon: Icons.arrow_drop_up,
                    tooltip: 'Saltar para Cima',
                    semanticsLabel: 'Saltar para Cima',
                    onPressed: activeStepKey == keyJumpUp ? onJumpUp : null,
                  ),
                  const SizedBox(height: 10),
                  JoystickButton(
                    key: keyJumpDown,
                    icon: Icons.arrow_drop_down,
                    tooltip: 'Saltar para Baixo',
                    semanticsLabel: 'Saltar para Baixo',
                    onPressed: activeStepKey == keyJumpDown ? onJumpDown : null,
                  ),
                ],
              ),
              const SizedBox(width: 1),
              JoystickButton(
                key: keyJumpRight,
                icon: Icons.arrow_right,
                tooltip: 'Saltar para Direita',
                semanticsLabel: 'Saltar para Direita',
                onPressed: activeStepKey == keyJumpRight ? onJumpRight : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
