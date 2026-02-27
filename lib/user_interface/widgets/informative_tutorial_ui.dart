import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/character_service.dart';
import '../../../services/palito_service.dart';
import 'grid_painter.dart';
import 'joystick_button.dart';
import 'menu_button.dart';

class InformativeTutorialUI extends StatelessWidget {
  final GlobalKey keyGrid;
  final GlobalKey keyPalitoButtons;
  final GlobalKey keyJoystick;
  final GlobalKey keyCharacter;
  final GlobalKey keyAutoJumpToggle;
  final GlobalKey keyPalitoV;
  final GlobalKey keyPalitoDD;
  final GlobalKey keyPalitoDE;
  final GlobalKey keyPalitoH;
  final GlobalKey keyJumpUp;
  final GlobalKey keyJumpDown;
  final GlobalKey keyJumpLeft;
  final GlobalKey keyJumpRight;
  final GlobalKey? activeStepKey;

  final bool isAutoJumpEnabled;
  final bool isJoystickLeft; // <--- NOVA PROPRIEDADE
  final ValueChanged<bool> onAutoJumpToggled;
  final VoidCallback onPalitoVTapped;
  final VoidCallback onPalitoDDTapped;
  final VoidCallback onPalitoDETapped;
  final VoidCallback onPalitoHTapped;
  final VoidCallback onJumpUp;
  final VoidCallback onJumpDown;
  final VoidCallback onJumpLeft;
  final VoidCallback onJumpRight;

  const InformativeTutorialUI({
    super.key,
    required this.keyGrid,
    required this.keyPalitoButtons,
    required this.keyJoystick,
    required this.keyCharacter,
    required this.keyAutoJumpToggle,
    required this.keyPalitoV,
    required this.keyPalitoDD,
    required this.keyPalitoDE,
    required this.keyPalitoH,
    required this.keyJumpUp,
    required this.keyJumpDown,
    required this.keyJumpLeft,
    required this.keyJumpRight,
    required this.isAutoJumpEnabled,
    this.isJoystickLeft = false, // Padrão é direita
    required this.onAutoJumpToggled,
    required this.onPalitoVTapped,
    required this.onPalitoDDTapped,
    required this.onPalitoDETapped,
    required this.onPalitoHTapped,
    required this.onJumpUp,
    required this.onJumpDown,
    required this.onJumpLeft,
    required this.onJumpRight,
    this.activeStepKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final characterCtrl =
            Provider.of<CharacterController>(context, listen: false);

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // GRADE
                      Positioned.fill(
                        key: keyGrid,
                        child: CustomPaint(
                          painter: GridPainter(
                            numColumns:
                                (w / characterCtrl.characterSize).floor(),
                            numRows:
                                (h / characterCtrl.characterSize).floor(),
                            cellSize: characterCtrl.characterSize,
                          ),
                        ),
                      ),
                      // PALITOS
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
                      // BOTÕES DE PALITO (Menu Esquerdo)
                       Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          key: keyPalitoButtons,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                MenuButton(
                                  key: keyPalitoV,
                                  iconPath: 'assets/images/Palito V.png',
                                  label: 'Palito V',
                                  tooltip: 'Palito Vertical',
                                  semanticsLabel: 'Palito Vertical',
                                  onTap: activeStepKey == keyPalitoV ? onPalitoVTapped : () {},
                                ),
                                MenuButton(
                                  key: keyPalitoDD,
                                  iconPath: 'assets/images/Palito DD.png',
                                  label: 'Palito DD',
                                  tooltip: 'Palito Diagonal à Direita',
                                  semanticsLabel: 'Palito Diagonal à Direita',
                                  onTap: activeStepKey == keyPalitoDD ? onPalitoDDTapped : () {},
                                ),
                                MenuButton(
                                  key: keyPalitoDE,
                                  iconPath: 'assets/images/Palito DE.png',
                                  label: 'Palito DE',
                                  tooltip: 'Palito Diagonal à Esquerda',
                                  semanticsLabel: 'Palito Diagonal à Esquerda',
                                  onTap: activeStepKey == keyPalitoDE ? onPalitoDETapped : () {},
                                ),
                                MenuButton(
                                  key: keyPalitoH,
                                  iconPath: 'assets/images/Palito H.png',
                                  label: 'Palito H',
                                  tooltip: 'Palito Horizontal',
                                  semanticsLabel: 'Palito Horizontal',
                                  onTap: activeStepKey == keyPalitoH ? onPalitoHTapped : () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // PERSONAGEM
                      Consumer<CharacterController>(
                        builder: (_, ctrl, __) => Positioned(
                          key: keyCharacter,
                          top: ctrl.yPosition,
                          left: ctrl.xPosition,
                          child: Image.asset(
                            'assets/images/personagem.png',
                            height: ctrl.characterSize,
                            width: ctrl.characterSize,
                          ),
                        ),
                      ),

                       // JOYSTICK (Movimenta-se baseada na propriedade isJoystickLeft)
                       Positioned(
                        bottom: 10,
                        // Se isJoystickLeft for true, fixa na esquerda (left: 16).
                        // Se for false, fixa na direita (right: 16).
                        left: isJoystickLeft ? 16 : null, 
                        right: isJoystickLeft ? null : 16,
                        child: Container(
                          key: keyJoystick,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              JoystickButton(
                                key: keyJumpLeft,
                                icon: Icons.arrow_left,
                                tooltip: 'Saltar para esquerda',
                                semanticsLabel: 'Saltar para esquerda',
                                onPressed: activeStepKey == keyJumpLeft ? onJumpLeft : null,
                              ),
                              const SizedBox(width: 1),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  JoystickButton(
                                    key: keyJumpUp,
                                    icon: Icons.arrow_drop_up,
                                    tooltip: "Saltar para cima",
                                    semanticsLabel: "Saltar para cima",
                                    onPressed: activeStepKey == keyJumpUp ? onJumpUp : null,
                                  ),
                                  const SizedBox(height: 10),
                                  JoystickButton(
                                    key: keyJumpDown,
                                    icon: Icons.arrow_drop_down,
                                    tooltip: "Saltar para baixo",
                                    semanticsLabel: "Saltar para baixo",
                                    onPressed: activeStepKey == keyJumpDown ? onJumpDown : null,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 1),
                              JoystickButton(
                                key: keyJumpRight,
                                icon: Icons.arrow_right,
                                tooltip: "Saltar para direita",
                                semanticsLabel: "Saltar para direita",
                                onPressed: activeStepKey == keyJumpRight ? onJumpRight : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}