import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';

class Mathsticks extends StatefulWidget {
  @override
  _MathsticksState createState() => _MathsticksState();
}

class _MathsticksState extends State<Mathsticks> {
  bool _showJoystick = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final controller = Provider.of<CharacterController>(context, listen: false);
    final palitoController = Provider.of<PalitoController>(context, listen: false);

    controller.setScreenSize(screenWidth, screenHeight);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Configurações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SwitchListTile(
              title: Text("Mostrar Joystick"),
              value: _showJoystick,
              onChanged: (bool value) {
                setState(() {
                  _showJoystick = value;
                });
              },
              secondary: Icon(
                _showJoystick ? Icons.gamepad : Icons.gamepad_outlined,
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("Limpar Tela"),
              leading: Icon(Icons.delete, color: Colors.red),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Limpar Tela"),
                      content: const Text(
                          "Tem certeza que deseja remover todos os palitos?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            palitoController.clearPalitos();
                            Navigator.of(context).pop();
                          },
                          child: Text("Limpar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.white,
        child: Column(
          children: [
            // Menu de botões e menu lateral no topo
            Container(
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(Icons.menu, color: Colors.blue),
                        tooltip: "Abrir menu",
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          iconPath: 'assets/images/palitov.png',
                          label: "Palito V",
                          tooltip: "Adicionar palito vertical",
                          semanticsLabel: "Adicionar palito vertical",
                          onTap: () {
                            final position = Offset(
                                controller.xPosition, controller.yPosition);
                            palitoController.addPalito(
                                position, "palitov", "Palito vertical");
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitodd.png',
                          label: "Palito DD",
                          tooltip: "Adicionar palito diagonal à direita",
                          semanticsLabel: "Adicionar palito diagonal à direita",
                          onTap: () {
                            final position = Offset(
                                controller.xPosition, controller.yPosition);
                            palitoController.addPalito(
                                position, "palitodd", "Palito diagonal à direita");
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitode.png',
                          label: "Palito DE",
                          tooltip: "Adicionar palito diagonal à esquerda",
                          semanticsLabel: "Adicionar palito diagonal à esquerda",
                          onTap: () {
                            final position = Offset(
                                controller.xPosition, controller.yPosition);
                            palitoController.addPalito(
                                position, "palitode", "Palito diagonal à esquerda");
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitoh.png',
                          label: "Palito H",
                          tooltip: "Adicionar palito horizontal",
                          semanticsLabel: "Adicionar palito horizontal",
                          onTap: () {
                            final position = Offset(
                                controller.xPosition, controller.yPosition);
                            palitoController.addPalito(
                                position, "palitoh", "Palito horizontal");
                          },
                        ),
                        Consumer<PalitoController>(
                          builder: (context, palitoController, child) {
                            return ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Contador de Palitos"),
                                      content: Text(
                                        "Há ${palitoController.palitos.length} palitos na tela.",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Row(
                                children:[
                                  Icon(Icons.countertops),
                                  SizedBox(width: 8),
                                  Text("Contar Palitos"),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Área de interação e movimentação
            Expanded(
              child: Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.blue.withOpacity(0.1),
                child: Stack(
                  children: [
                    Consumer<PalitoController>(
                      builder: (context, palitoController, child) {
                        return Stack(
                          children: palitoController.palitos.map((palito) {
                            return Positioned(
                              top: palito.position.dy,
                              left: palito.position.dx,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Remover Palito"),
                                        content:
                                            Text("Deseja remover este palito?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              palitoController.removePalito(palito);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Remover"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Semantics(
                                  label: palito.semanticsLabel,
                                  child: Image.asset(
                                    'assets/images/${palito.type}.png',
                                    height: 100,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    Consumer<CharacterController>(
                      builder: (context, controller, child) {
                        return Positioned(
                          top: controller.yPosition,
                          left: controller.xPosition,
                          child: Image.asset(
                            'assets/images/personagem.png',
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                    if (_showJoystick)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            JoystickButton(
                              icon: Icons.arrow_left,
                              onPressed: () => controller.moveLeft(),
                              tooltip: "Mover para a esquerda",
                              semanticsLabel: "Botão de direção: esquerda",
                            ),
                            const SizedBox(width: 2),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                JoystickButton(
                                  icon: Icons.arrow_drop_up,
                                  onPressed: () => controller.moveUp(),
                                  tooltip: "Mover para cima",
                                  semanticsLabel: "Botão de direção: cima",
                                ),
                                const SizedBox(height: 20),
                                JoystickButton(
                                  icon: Icons.arrow_drop_down,
                                  onPressed: () => controller.moveDown(),
                                  tooltip: "Mover para baixo",
                                  semanticsLabel: "Botão de direção: baixo",
                                ),
                              ],
                            ),
                            const SizedBox(width: 2),
                            JoystickButton(
                              icon: Icons.arrow_right,
                              onPressed: () => controller.moveRight(),
                              tooltip: "Mover para a direita",
                              semanticsLabel: "Botão de direção: direita",
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/character_service.dart';
// import '../../services/palito_service.dart';
// import '../widgets/joystick_button.dart'; // Importe o novo widget
// import '../widgets/menu_button.dart';

// class Mathsticks extends StatefulWidget {
//   @override
//   _MathsticksState createState() => _MathsticksState();
// }

// class _MathsticksState extends State<Mathsticks> {
//   bool _showJoystick = true; // Controla a visibilidade do joystick

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     final controller = Provider.of<CharacterController>(context, listen: false);
//     final palitoController =
//         Provider.of<PalitoController>(context, listen: false);

//     controller.setScreenSize(screenWidth, screenHeight);

//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text(
//                 'Configurações',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             SwitchListTile(
//               title: Text("Mostrar Joystick"),
//               value: _showJoystick,
//               onChanged: (bool value) {
//                 setState(() {
//                   _showJoystick = value;
//                 });
//               },
//               secondary: Icon(
//                 _showJoystick ? Icons.gamepad : Icons.gamepad_outlined,
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               title: Text("Limpar Tela"),
//               leading: Icon(Icons.delete, color: Colors.red),
//               onTap: () {
//                 // Mostra um dialog para confirmar a ação
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: Text("Limpar Tela"),
//                       content: const Text(
//                           "Tem certeza que deseja remover todos os palitos?"),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop(); // Fecha o diálogo
//                           },
//                           child: Text("Cancelar"),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             // Remove todos os palitos
//                             palitoController.clearPalitos();
//                             Navigator.of(context).pop(); // Fecha o diálogo
//                           },
//                           child: Text("Limpar"),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         width: screenWidth,
//         height: screenHeight,
//         color: Colors.white,
//         child: Column(
//           children: [
//             // Menu de botões e menu lateral no topo
//             Container(
//               child: Row(
//                 children: [
//                   // Botão para abrir o menu lateral
//                   Builder(
//                     builder: (context) {
//                       return IconButton(
//                         icon: Icon(Icons.menu, color: Colors.blue),
//                         tooltip: "Abrir menu",
//                         onPressed: () {
//                           Scaffold.of(context).openDrawer();
//                         },
//                       );
//                     },
//                   ),

//                   // Botões de palitos
//                  // Dentro do Row onde estão os botões de palitos
// Expanded(
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       MenuButton(
//         iconPath: 'assets/images/palitov.png',
//         label: "Palito V",
//         tooltip: "Adicionar palito vertical",
//         semanticsLabel: "Adicionar palito vertical",
//         onTap: () {
//           final position = Offset(controller.xPosition, controller.yPosition);
//           palitoController.addPalito(position, "palitov", "Palito vertical");
//         },
//       ),
//       MenuButton(
//         iconPath: 'assets/images/palitodd.png',
//         label: "Palito DD",
//         tooltip: "Adicionar palito diagonal à direita",
//         semanticsLabel: "Adicionar palito diagonal à direita",
//         onTap: () {
//           final position = Offset(controller.xPosition, controller.yPosition);
//           palitoController.addPalito(position, "palitodd", "Palito diagonal à direita");
//         },
//       ),
//       MenuButton(
//         iconPath: 'assets/images/palitode.png',
//         label: "Palito DE",
//         tooltip: "Adicionar palito diagonal à esquerda",
//         semanticsLabel: "Adicionar palito diagonal à esquerda",
//         onTap: () {
//           final position = Offset(controller.xPosition, controller.yPosition);
//           palitoController.addPalito(position, "palitode", "Palito diagonal à esquerda");
//         },
//       ),
//       MenuButton(
//         iconPath: 'assets/images/palitoh.png',
//         label: "Palito H",
//         tooltip: "Adicionar palito horizontal",
//         semanticsLabel: "Adicionar palito horizontal",
//         onTap: () {
//           final position = Offset(controller.xPosition, controller.yPosition);
//           palitoController.addPalito(position, "palitoh", "Palito horizontal");
//         },
//       ),
//       // Botão do contador de palitos
//       Consumer<PalitoController>(
//         builder: (context, palitoController, child) {
//           return ElevatedButton(
//             onPressed: () {
//               // Mostra a quantidade em uma telinha ao lado
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text("Contador de Palitos"),
//                     content: Text(
//                       "Há ${palitoController.palitos.length} palitos na tela.",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: Text("OK"),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Row(
//               children: [
//                 Icon(Icons.countertops), // Ícone para o contador
//                 SizedBox(width: 8),
//                 Text("Contar Palitos"),
//               ],
//             ),
//           );
//         },
//       ),
//     ],
//   ),
// ),

//             // Área de interação e movimentação
//             Expanded(
//               // child: GestureDetector(
//               //   onPanUpdate: (details) {
//               //     // Detecta a direção do gesto e movimenta o personagem
//               //     final dx = details.delta.dx;
//               //     final dy = details.delta.dy;

//               //     if (dx.abs() > dy.abs()) {
//               //       if (dx > 0) {
//               //         controller.moveRight(); // Direita
//               //       } else {
//               //         controller.moveLeft(); // Esquerda
//               //       }
//               //     } else {
//               //       if (dy > 0) {
//               //         controller.moveDown(); // Para baixo
//               //       } else {
//               //         controller.moveUp(); // Para cima
//               //       }
//               //     }
//               //   },
//               child: Container(
//                 width: screenWidth,
//                 height: screenHeight,
//                 color: Colors.blue.withOpacity(0.1),
//                 child: Stack(
//                   children: [
//                     Consumer<PalitoController>(
//                       builder: (context, palitoController, child) {
//                         return Stack(
//                           children: palitoController.palitos.map((palito) {
//                             return Positioned(
//                               top: palito.position.dy,
//                               left: palito.position.dx,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   // Mostra um dialog para confirmar a remoção
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         title: Text("Remover Palito"),
//                                         content:
//                                             Text("Deseja remover este palito?"),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context)
//                                                   .pop(); // Fecha o diálogo
//                                             },
//                                             child: Text("Cancelar"),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               palitoController
//                                                   .removePalito(palito);
//                                               Navigator.of(context)
//                                                   .pop(); // Fecha o diálogo
//                                             },
//                                             child: Text("Remover"),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                                 child: Semantics(
//                                   label: palito.semanticsLabel,
//                                   child: Image.asset(
//                                     'assets/images/${palito.type}.png', // Certifique-se de que o tipo corresponde ao nome da imagem
//                                     height: 100, // Ajuste o tamanho do palito
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         );
//                       },
//                     ),
//                     // Renderiza o personagem na tela
//                     Consumer<CharacterController>(
//                       builder: (context, controller, child) {
//                         return Positioned(
//                           top: controller.yPosition,
//                           left: controller.xPosition,
//                           child: Image.asset(
//                             'assets/images/personagem.png',
//                             height: 70,
//                             fit: BoxFit.contain,
//                           ),
//                         );
//                       },
//                     ),
//                     if (_showJoystick)
//                       Positioned(
//                         bottom:
//                             16, // Define a distância da parte inferior da tela
//                         left: 0,
//                         right:
//                             0, // Faz com que o Row ocupe a largura completa da tela
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment
//                               .center, // Centraliza horizontalmente
//                           children: [
//                             JoystickButton(
//                               icon: Icons.arrow_left,
//                               onPressed: () => controller.moveLeft(),
//                               tooltip: "Mover para a esquerda",
//                               semanticsLabel: "Botão de direção: esquerda",
//                             ),
//                             const SizedBox(width: 2),
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 JoystickButton(
//                                   icon: Icons.arrow_drop_up,
//                                   onPressed: () => controller.moveUp(),
//                                   tooltip: "Mover para cima",
//                                   semanticsLabel: "Botão de direção: cima",
//                                 ),
//                                 const SizedBox(height: 20),
//                                 JoystickButton(
//                                   icon: Icons.arrow_drop_down,
//                                   onPressed: () => controller.moveDown(),
//                                   tooltip: "Mover para baixo",
//                                   semanticsLabel: "Botão de direção: baixo",
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 2),
//                             JoystickButton(
//                               icon: Icons.arrow_right,
//                               onPressed: () => controller.moveRight(),
//                               tooltip: "Mover para a direita",
//                               semanticsLabel: "Botão de direção: direita",
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // ),
//             ),
//           ],
//         ),
//       ),
//       ),
//       ),
//       );
//   }
// }
