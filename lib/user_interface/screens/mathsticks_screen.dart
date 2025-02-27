import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
// import '../widgets/action_button.dart';
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
  //int _repeatCount = 1; // Valor padrão: 1 vez
  double _narrationSpeed = 1.0; // Velocidade da narração
  bool _isNarrationEnabled = true; // Adiciona controle de narração

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

  Future<void> _executeActions() async {
    for (final actionSet in actionSets) {
      int repeatCount = actionSet['n'] as int;
      List<StoryAction> actions = actionSet['actions'] as List<StoryAction>;
      for (int i = 0; i < repeatCount; i++) {
        for (StoryAction action in actions) {
          if (action.type == StoryActionType.move) {
            await _moveCharacter(action.direction!);
          } else {
            await _addPalito(action);
          }

          if (_isNarrationEnabled) {
            // Adiciona delay apenas se a narração estiver ativa
            await Future.delayed(const Duration(milliseconds: 1600));
          }
        }
      }
    }
  }

  static final Map<String, String> _actionLabels = {
    'palitov': 'Palito Vertical',
    'palitoh': 'Palito Horizontal',
    'palitodd': 'Palito Diagonal à Direita',
    'palitode': 'Palito Diagonal à Esquerda',
    'Cima': 'Mover para Cima',
    'Baixo': 'Mover para Baixo',
    'Esquerda': 'Mover para Esquerda',
    'Direita': 'Mover para Direita',
  };

  static String _getActionLabel(String actionValue) {
    return _actionLabels[actionValue] ??
        actionValue; // Retorna o nome amigável ou o valor original se não houver mapeamento
  }

  Future<void> _moveCharacter(String direction) async {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);

    // Primeiro executa a ação de movimento
    switch (direction) {
      case 'Cima':
        characterController.moveUp();
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/cima.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case 'Baixo':
        characterController.moveDown();
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/baixo.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case 'Esquerda':
        characterController.moveLeft();
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/esquerda.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case 'Direita':
        characterController.moveRight();
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/direita.mp3',
            speed: _narrationSpeed,
          );
        }
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

    switch (action.palitoType) {
      case "palitov":
        baseOffsetX = 40;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoVertical.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "palitodd":
        baseOffsetX = 52;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoDiagonalDireita.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "palitode":
        baseOffsetX = 27;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoDiagonalEsquerda.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "palitoh":
        baseOffsetX = 65;
        baseOffsetY = -2;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoHorizontal.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      default:
        baseOffsetX = 0;
        baseOffsetY = 0;
    }

    final sizeDiff = action.size! - baseSize;
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

    final position = Offset(
      characterController.xPosition + offsetX,
      characterController.yPosition + offsetY,
    );

    // Independentemente de narração ativa ou não, o palito é criado
    palitoController.addPalito(
      position,
      action.palitoType!,
      action.palitoType!,
      action.size!,
    );
  }

  String? _selectedMoveAction; // Valor inicial do dropdown para movimentos
  String? _selectedPalitoAction; // Valor inicial do dropdown para palitos
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> actionSets = [
    {'n': 1, 'actions': <StoryAction>[]} // Conjunto inicial
  ];

  void _showCreateStoryModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          title: const Center(child: Text("Selecione as ações:")),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: SizedBox(
                        height: actions.length > 2 ? 100 : null,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              // Conjuntos de ações
                              for (var i = 0; i < actionSets.length; i++) ...[
                                Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          actionSets[i]['actions'].length > 2
                                              ? 100
                                              : null,
                                      child: SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Column(
                                          children: [
                                            for (int j = 0;
                                                j <
                                                    actionSets[i]['actions']
                                                        .length;
                                                j++)
                                              ListTile(
                                                title: Text(_getActionLabel(
                                                    actionSets[i]['actions'][j]
                                                            .direction ??
                                                        actionSets[i]['actions']
                                                                [j]
                                                            .palitoType ??
                                                        '')),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        IconData(0x2715,
                                                            fontFamily:
                                                                'MaterialIcons'), // Caractere Unicode "x"
                                                        color: Colors.black,
                                                        size: 12,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          actionSets[i]
                                                                  ['actions']
                                                              .removeAt(
                                                                  j); // Remove apenas a ação
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                        // padding: const EdgeInsets.symmetric(
                                        //     horizontal: 1, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey[400]!),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${i + 1}: n = '),
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  if (actionSets[i]['n'] > 0) {
                                                    actionSets[i]['n']--;
                                                  }
                                                });
                                              },
                                            ),
                                            Text('${actionSets[i]['n']}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  actionSets[i]['n']++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (i <
                                        actionSets.length -
                                            1) // Adiciona o Divider
                                      const Divider(
                                        thickness: 2,
                                        color: Colors.grey,
                                      ),

                                    const SizedBox(height: 10),
                                    // Dropdowns para ações
                                  ],
                                ),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        actionSets.add({
                                          'n': 1,
                                          'actions': <StoryAction>[]
                                        });
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      minimumSize: const Size(40, 40),
                                    ),
                                    child: const Icon(Icons.add),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        actionSets = [
                                          {'n': 1, 'actions': <StoryAction>[]}
                                        ];
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      minimumSize: const Size(40, 40),
                                    ),
                                    child: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  DropdownButton<String>(
                                    value: _selectedMoveAction,
                                    hint: const Text("Movimentação"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedMoveAction = newValue;
                                        if (newValue != null) {
                                          final newAction = StoryAction(
                                            type: StoryActionType.move,
                                            direction: newValue,
                                            getActionLabel: _getActionLabel,
                                          );

                                          actionSets.last['actions']
                                              .add(newAction);
                                          _moveCharacter(newValue);
                                        }
                                      });
                                    },
                                    items: <String?>[
                                      null,
                                      'Cima',
                                      'Baixo',
                                      'Esquerda',
                                      'Direita'
                                    ].map<DropdownMenuItem<String>>(
                                        (String? value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value != null
                                            ? _getActionLabel(value)
                                            : "Movimentação"),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(width: 20),
                                  DropdownButton<String>(
                                    value: _selectedPalitoAction,
                                    hint: const Text("Palitos"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedPalitoAction = newValue;
                                        if (newValue != null) {
                                          final newAction = StoryAction(
                                            type: StoryActionType.palito,
                                            palitoType: newValue,
                                            size: _palitoSize,
                                            getActionLabel: _getActionLabel,
                                          );
                                          // Adiciona a ação ao último conjunto
                                          actionSets.last['actions']
                                              .add(newAction);
                                          _addPalito(newAction);
                                        }
                                      });
                                    },
                                    items: <String?>[
                                      null,
                                      'palitov',
                                      'palitoh',
                                      'palitodd',
                                      'palitode'
                                    ].map<DropdownMenuItem<String>>(
                                        (String? value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value != null
                                            ? _getActionLabel(value)
                                            : "Palitos"),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Ativar Narração"),
                      value: _isNarrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isNarrationEnabled = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _executeActions(); // Chama _executeActions sem parâmetros
                      },
                      child: const Text("Fazer História"),
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

  int _palitoCount = 0;
  bool _showCount = false;

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
                    _audioService.setSpeed(
                        _narrationSpeed); // Atualiza a velocidade no AudioService
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            return Column(
                              children: [
                                if (_showCount) // Exibe a contagem apenas se _showCount for true
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    color: Colors.orange[100],
                                    child: Text(
                                      '$_palitoCount',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _palitoCount =
                                          palitoController.palitos.length;
                                      _showCount =
                                          !_showCount; // Alterna a visibilidade
                                    });
                                  },
                                  child: const Row(
                                    children: [
                                      // Icon(Icons.countertops),
                                      SizedBox(width: 8),
                                      Text("Quantidade"),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showCreateStoryModal(context);
                          },
                          child: const Row(
                            // Usar Row para ícone e texto
                            mainAxisSize: MainAxisSize
                                .min, // Ocupar apenas o espaço necessário
                            children: [
                              // Icon(Icons.history_edu,
                              //     color: Colors.blue), // Ícone
                              SizedBox(
                                  width: 8), // Espaçamento entre ícone e texto
                              Text("História"), // Texto
                            ],
                          ),
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
