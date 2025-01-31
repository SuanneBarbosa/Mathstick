import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
// import '../widgets/action_button.dart';
// import '../../data/action.dart';

class Mathsticks extends StatefulWidget {
  @override
  _MathsticksState createState() => _MathsticksState();
}

class _MathsticksState extends State<Mathsticks> {
  bool _showJoystick = true;
  double _palitoSize = 70.0; // Tamanho inicial do palito
  Offset? _initialDragPosition;
  List<Action> actions = []; // Lista para armazenar as ações

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final characterController =
          Provider.of<CharacterController>(context, listen: false);
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      characterController.setScreenSize(screenWidth, screenHeight);
    });
  }

  void updateStepSize() {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    setState(() {
      characterController.setStepSize(_palitoSize);
    });
  }

  // void _executeActions() {
  //   for (Action action in _actions) {
  //     if (action.type == StoryActionType.move) {
  //       _moveCharacter(action.direction!);
  //     } else {
  //       _addPalito(action);
  //     }
  //   }
  //   _actions.clear(); // Limpa a lista de ações após a execução.
  // }

  void _moveCharacter(String direction) {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    switch (direction) {
      case 'Cima':
        characterController.moveUp();
        break;
      case 'Baixo':
        characterController.moveDown();
        break;
      case 'Esquerda':
        characterController.moveLeft();
        break;
      case 'Direita':
        characterController.moveRight();
        break;
    }
  }

  // void _addPalito(Action action) {
  //   final palitoController =
  //       Provider.of<PalitoController>(context, listen: false);
  //   final characterController =
  //       Provider.of<CharacterController>(context, listen: false);
  //   const double baseSize = 50;
  //   const double baseOffsetX = 40; // Valor base para o offset X
  //   const double baseOffsetY = -25; // Valor base para o offset Y

  //   final sizeDiff = action.size! - baseSize; // Diferença de tamanho

  //   double offsetX = 0, offsetY = 0;
  //   if (action.palitoType == "palitov") {
  //     offsetX = baseOffsetX - (sizeDiff / 10) * 5;
  //     offsetY = baseOffsetY - (sizeDiff / 10) * 10;
  //   } else if (action.palitoType == "palitoh") {
  //     offsetY = baseOffsetY - (sizeDiff / 10) * 5;
  //     offsetX = baseOffsetX + 25;
  //   } else if (action.palitoType == "palitodd") {
  //     offsetX = baseOffsetX + 12 - (sizeDiff / 10) * 3;
  //     offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
  //   } else {
  //     offsetX = baseOffsetX - 13 - (sizeDiff / 10) * 6;
  //     offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
  //   }

  //   final position = Offset(characterController.xPosition + offsetX,
  //       characterController.yPosition + offsetY);

  //   palitoController.addPalito(
  //       position, action.palitoType!, action.palitoType!, action.size!);
  // }

  // void _showCreateStoryModal(BuildContext context) {
    

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Criar História"),
  //         content: StatefulBuilder(
  //           // Usando StatefulBuilder para gerenciar o estado interno do modal
  //           builder: (context, setState) {
  //             return SingleChildScrollView(
  //               // Para rolagem se a lista de ações ficar grande
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.move,
  //                           value: 'Cima'),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.move,
  //                           value: 'Baixo'),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.move,
  //                           value: 'Esquerda'),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.move,
  //                           value: 'Direita'),
  //                     ],
  //                   ),

  //                   Wrap(
  //                     alignment: WrapAlignment.center,
  //                     children: [
  //                       ActionButton(
  //                         onActionAdded: (action) => setState(() {
  //                           _actions.add(action);
  //                         }),
  //                         type: StoryActionType.palito,
  //                         value: 'palitov',
  //                         palitoSize: _palitoSize,
  //                       ),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.palito,
  //                           value: 'palitoh',
  //                           palitoSize: _palitoSize),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.palito,
  //                           value: 'palitodd',
  //                           palitoSize: _palitoSize),
  //                       ActionButton(
  //                           onActionAdded: (action) => setState(() {
  //                                 _actions.add(action);
  //                               }),
  //                           type: StoryActionType.palito,
  //                           value: 'palitode',
  //                           palitoSize: _palitoSize),
  //                     ],
  //                   ),

  //                   // Lista de ações adicionadas
  //                   ..._actions
  //                       .map((action) =>
  //                           ListTile(title: Text(action.toString())))
  //                       .toList(),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       // Executar as ações (veremos mais tarde)
  //                       Navigator.of(context).pop(); // Fecha o modal
  //                     },
  //                     child: Text("Criar História"),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final controller = Provider.of<CharacterController>(context, listen: false);
    final palitoController =
        Provider.of<PalitoController>(context, listen: false);

    // controller.setScreenSize(screenWidth, screenHeight);

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
            ListTile(
              title: Text("Tamanho do Palito"),
              subtitle: Consumer<CharacterController>(
                builder: (context, characterController, child) {
                  return Slider(
                    value: _palitoSize,
                    min: 50.0,
                    max: 120.0,
                    divisions: 7,
                    label: _palitoSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _palitoSize = value;
                        characterController.setStepSize(value);
                      });
                    },
                  );
                },
              ),
            ),
            // ListTile(
            //   title: Text("Criar História"),
            //   leading:
            //       Icon(Icons.history_edu, color: Colors.blue), // Ícone adequado
            //   onTap: () {
            //     _showCreateStoryModal(
            //         context); // Chama a função para abrir o modal
            //   },
            // )
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
                            const double baseSize = 50;
                            const double baseOffsetX = 40;
                            const double baseOffsetY = -25;
                            final sizeDiff = _palitoSize - baseSize;
                            final offsetX = baseOffsetX - (sizeDiff / 10) * 5;
                            final offsetY = baseOffsetY - (sizeDiff / 10) * 10;
                            final position = Offset(
                                controller.xPosition + offsetX,
                                controller.yPosition + offsetY);
                            palitoController.addPalito(position, "palitov",
                                "Palito vertical", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitodd.png',
                          label: "Palito DD",
                          tooltip: "Adicionar palito diagonal à direita",
                          semanticsLabel: "Adicionar palito diagonal à direita",
                          onTap: () {
                            const double baseSize = 50;
                            const double baseOffsetX = 52;
                            const double baseOffsetY = -25;

                            final sizeDiff = _palitoSize - baseSize;
                            final offsetX = baseOffsetX - (sizeDiff / 10) * 3;
                            final offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;

                            final position = Offset(
                                controller.xPosition + offsetX,
                                controller.yPosition + offsetY);
                            palitoController.addPalito(position, "palitodd",
                                "Palito diagonal à direita", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitode.png',
                          label: "Palito DE",
                          tooltip: "Adicionar palito diagonal à esquerda",
                          semanticsLabel:
                              "Adicionar palito diagonal à esquerda",
                          onTap: () {
                            const double baseSize = 50;
                            const double baseOffsetX = 27;
                            const double baseOffsetY = -25;

                            final sizeDiff = _palitoSize - baseSize;
                            final offsetX = baseOffsetX - (sizeDiff / 10) * 6;
                            final offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;

                            final position = Offset(
                                controller.xPosition + offsetX,
                                controller.yPosition + offsetY);
                            palitoController.addPalito(position, "palitode",
                                "Palito diagonal à esquerda", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/palitoh.png',
                          label: "Palito H",
                          tooltip: "Adicionar palito horizontal",
                          semanticsLabel: "Adicionar palito horizontal",
                          onTap: () {
                            const double baseSize = 50;
                            const double baseOffsetX = 65;
                            const double baseOffsetY = -2;
                            final sizeDiff = _palitoSize - baseSize;
                            final offsetY = baseOffsetY - (sizeDiff / 10) * 5;
                            final position = Offset(
                                controller.xPosition + baseOffsetX,
                                controller.yPosition + offsetY);
                            palitoController.addPalito(position, "palitoh",
                                "Palito horizontal", _palitoSize);
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
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: const Row(
                                children: [
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
                                              palitoController
                                                  .removePalito(palito);
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
                                    height: palito.size,
                                    fit: BoxFit.contain,
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
                          child: GestureDetector(
                            onPanStart: (details) {
                              _initialDragPosition = details.globalPosition;
                            },
                            onPanUpdate: (details) {
                              if (_initialDragPosition != null) {
                                final dragDelta = details.globalPosition -
                                    _initialDragPosition!;
                                final stepSize = _palitoSize;

                                if (dragDelta.dx.abs() > stepSize ||
                                    dragDelta.dy.abs() > stepSize) {
                                  if (dragDelta.dx.abs() > dragDelta.dy.abs()) {
                                    if (dragDelta.dx > 0) {
                                      controller.moveRight();
                                    } else {
                                      controller.moveLeft();
                                    }
                                  } else {
                                    if (dragDelta.dy > 0) {
                                      controller.moveDown();
                                    } else {
                                      controller.moveUp();
                                    }
                                  }
                                  _initialDragPosition = details.globalPosition;
                                }
                              }
                            },
                            child: Image.asset(
                              'assets/images/personagem.png',
                              height: 70,
                              fit: BoxFit.contain,
                            ),
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
