import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
import '../widgets/action_button.dart';
import '../../data/story_action.dart';
import '../../services/audio_service.dart';


class Mathsticks extends StatefulWidget {
  const Mathsticks({super.key});

  @override
  _MathsticksState createState() => _MathsticksState();
}

class _MathsticksState extends State<Mathsticks> {
  bool _showJoystick = true;
  double _palitoSize = 70.0; // Tamanho inicial do palito
  Offset? _initialDragPosition;
  List<StoryAction> actions = []; // Lista para armazenar as ações
  final AudioService _audioService =
      AudioService(); // Instância do serviço de áudio
  int _repeatCount = 1; // Valor padrão: 1 vez
  double _narrationSpeed = 1.0; // Velocidade da narração

  @override
  void dispose() {
    _audioService.dispose(); // Libera o player quando o widget for descartado
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        final characterController =
            Provider.of<CharacterController>(context, listen: false);
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth > 1 && screenHeight > 1) {
          characterController.setScreenSize(screenWidth, screenHeight);
        }
      });
    });
  }

  void updateStepSize() {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    setState(() {
      characterController.setStepSize(_palitoSize);
    });
  }

   Future<void> _executeActions(int repeatCount) async {
    for (int i = 0; i < repeatCount; i++) {
      print("Repetição ${i + 1} de $repeatCount");

      for (StoryAction action in actions) {
        if (action.type == StoryActionType.move) {
          await _moveCharacter(action.direction!);
        } else {
          await _addPalito(action);
        }
        await Future.delayed(
            const Duration(milliseconds: 1600)); // Pequeno delay entre ações
      }
    }
  }

  Future<void> _moveCharacter(String direction) async {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    switch (direction) {
      case 'Cima':
        characterController.moveUp();
        await _audioService.playAudio('assets/sounds/cima.mp3', speed: _narrationSpeed);
        break;
      case 'Baixo':
        characterController.moveDown();
        await _audioService.playAudio('assets/sounds/baixo.mp3', speed: _narrationSpeed);
        break;
      case 'Esquerda':
        characterController.moveLeft();
        await _audioService.playAudio('assets/sounds/esquerda.mp3', speed: _narrationSpeed);
        break;
      case 'Direita':
        characterController.moveRight();
        await _audioService.playAudio('assets/sounds/direita.mp3', speed: _narrationSpeed);
        break;
    }
  }

  Future<void> _addPalito(StoryAction action) async {
    final palitoController =
        Provider.of<PalitoController>(context, listen: false);
    final characterController =
        Provider.of<CharacterController>(context, listen: false);

    const double baseSize = 50;
    double baseOffsetX = 0;
    double baseOffsetY = 0;

    // Defina os valores base de offset para cada tipo de palito
    switch (action.palitoType) {
      case "palitov":
        baseOffsetX = 40;
        baseOffsetY = -25;
        await _audioService.playAudio('assets/sounds/palitoVertical.mp3', speed: _narrationSpeed);
        break;
      case "palitodd":
        baseOffsetX = 52;
        baseOffsetY = -25;
        await _audioService
            .playAudio('assets/sounds/palitoDiagonalDireita.mp3', speed: _narrationSpeed);
        break;
      case "palitode":
        baseOffsetX = 27;
        baseOffsetY = -25;
        await _audioService
            .playAudio('assets/sounds/palitoDiagonalEsquerda.mp3', speed: _narrationSpeed);
        break;
      case "palitoh":
        baseOffsetX = 65;
        baseOffsetY = -2;
        await _audioService.playAudio('assets/sounds/palitoHorizontal.mp3', speed: _narrationSpeed);
        break;
      default:
        baseOffsetX = 0;
        baseOffsetY = 0;
    }

    // Calcule as diferenças de tamanho
    final sizeDiff = action.size! - baseSize;

    // Ajuste os offsets com base no tipo de palito
    double offsetX = 0, offsetY = 0;
    if (action.palitoType == "palitov") {
      offsetX = baseOffsetX - (sizeDiff / 10) * 5;
      offsetY = baseOffsetY - (sizeDiff / 10) * 10;
    } else if (action.palitoType == "palitoh") {
      offsetY = baseOffsetY - (sizeDiff / 10) * 5;
      offsetX = baseOffsetX;
    } else if (action.palitoType == "palitodd") {
      offsetX = baseOffsetX - (sizeDiff / 10) * 3;
      offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
    } else if (action.palitoType == "palitode") {
      offsetX = baseOffsetX - (sizeDiff / 10) * 6;
      offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
    }

    // Calcule a posição final
    final position = Offset(
      characterController.xPosition + offsetX,
      characterController.yPosition + offsetY,
    );

    // Adicione o palito na posição correta
    palitoController.addPalito(
      position,
      action.palitoType!,
      action.palitoType!,
      action.size!,
    );
  }


  String _getPalitoAudioFile(String palitoType) {  //Função auxiliar para nome do arquivo
    switch (palitoType) {
      case "palitov":
        return "palitoVertical";
      case "palitodd":
        return "palitoDiagonalDireita";
      case "palitode":
        return "palitoDiagonalEsquerda";
      case "palitoh":
        return "palitoHorizontal";
      default:
        return ""; // Ou algum áudio padrão
    }
  }

  void _showCreateStoryModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("História"),
          content: StatefulBuilder(
            // Usando StatefulBuilder para gerenciar o estado interno do modal
            builder: (context, setState) {
              return SingleChildScrollView(
                // Para rolagem se a lista de ações ficar grande
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _moveCharacter(action.direction!);
                            });
                          },
                          type: StoryActionType.move,
                          value: 'Cima',
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _moveCharacter(action.direction!);
                            });
                          },
                          type: StoryActionType.move,
                          value: 'Baixo',
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _moveCharacter(action.direction!);
                            });
                          },
                          type: StoryActionType.move,
                          value: 'Esquerda',
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _moveCharacter(action.direction!);
                            });
                          },
                          type: StoryActionType.move,
                          value: 'Direita',
                        ),
                      ],
                    ),

                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _addPalito(action);
                            });
                          },
                          type: StoryActionType.palito,
                          value: 'palitov',
                          palitoSize: _palitoSize,
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _addPalito(action);
                            });
                          },
                          type: StoryActionType.palito,
                          value: 'palitoh',
                          palitoSize: _palitoSize,
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _addPalito(action);
                            });
                          },
                          type: StoryActionType.palito,
                          value: 'palitodd',
                          palitoSize: _palitoSize,
                        ),
                        ActionButton(
                          onActionAdded: (action) {
                            setState(() {
                              actions.add(action);
                              _addPalito(action);
                            });
                          },
                          type: StoryActionType.palito,
                          value: 'palitode',
                          palitoSize: _palitoSize,
                        ),
                      ],
                    ),

                    // Lista de ações adicionadas
                    ...actions.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final action = entry.value;

                        return ListTile(
                          title: Text(action.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botão para mover para cima
                              IconButton(
                                icon: const Icon(Icons.arrow_upward,
                                    color: Colors.blue),
                                onPressed: index > 0
                                    ? () {
                                        setState(() {
                                          final temp = actions[index];
                                          actions[index] = actions[index - 1];
                                          actions[index - 1] = temp;
                                        });
                                      }
                                    : null, // Desativa se for o primeiro item
                              ),
                              // Botão para mover para baixo
                              IconButton(
                                icon: const Icon(Icons.arrow_downward,
                                    color: Colors.blue),
                                onPressed: index < actions.length - 1
                                    ? () {
                                        setState(() {
                                          final temp = actions[index];
                                          actions[index] = actions[index + 1];
                                          actions[index + 1] = temp;
                                        });
                                      }
                                    : null, // Desativa se for o último item
                              ),
                              // Botão para excluir ação
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    actions.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          actions.clear(); // Limpa a lista de ações
                        });
                      },
                      child: const Text(
                        "Limpar Ações",
                        style: TextStyle(
                            color: Colors
                                .red), // Deixa o botão vermelho para destacar
                      ),
                    ),

                    TextField(
                    decoration: const InputDecoration(
                      labelText: "Repetições (n)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _repeatCount = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                     ElevatedButton(
                    onPressed: () {
                      print("Executando história $_repeatCount vezes...");
                      _executeActions(_repeatCount); // Chamar com repetição
                    },
                    child: const Text("Criar História"),
                  ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth <= 1 || screenHeight <= 1) {
      return const Center(
          child: CircularProgressIndicator()); // Espera até ter valores válidos
    }

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
              title: const Text("Mostrar Joystick"),
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
              title: const Text("Limpar Tela"),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Limpar Tela"),
                      content: const Text(
                          "Tem certeza que deseja remover todos os palitos?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            palitoController.clearPalitos();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Limpar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text("Tamanho do Palito"),
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
             ListTile(
          title: const Text("Velocidade da Narração"),
          subtitle: Slider(
            value: _narrationSpeed,
            min: 0.7,
            max: 2.0,
            divisions: 8,
            label: _narrationSpeed.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _narrationSpeed = value;
                _audioService.setSpeed(_narrationSpeed); // Atualiza a velocidade no AudioService
              });
            },
          ),
        ),
            ListTile(
              title: const Text("Criar História"),
              leading: const Icon(Icons.history_edu,
                  color: Colors.blue), // Ícone adequado
              onTap: () {
                _showCreateStoryModal(
                    context); // Chama a função para abrir o modal
              },
            )
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
                        icon: const Icon(Icons.menu, color: Colors.blue),
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
                                      title: const Text("Contador de Palitos"),
                                      content: Text(
                                        "Há ${palitoController.palitos.length} palitos na tela.",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("OK"),
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
                            final wrappedPosition = palito.getWrappedPosition(
                                screenWidth, screenHeight);
                            return Positioned(
                              top: wrappedPosition.dy,
                              left: wrappedPosition.dx,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Remover Palito"),
                                        content: const Text(
                                            "Deseja remover este palito?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              palitoController
                                                  .removePalito(palito);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Remover"),
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
