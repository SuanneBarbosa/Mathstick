import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
// import '../widgets/action_button.dart';
import '../../data/story_action.dart';
import '../../services/audio_service.dart';
import 'package:flutter/services.dart'; // desativar controles do sistema (relógio, barra de status, botões de navegação)

class DropdownOption {
  final String value;
  final String label;
  final StoryActionType type;

  DropdownOption(
      {required this.value, required this.label, required this.type});
}

class Mathsticks extends StatefulWidget {
  const Mathsticks({super.key});

  @override
  _MathsticksState createState() => _MathsticksState();
}

class _MathsticksState extends State<Mathsticks> {
  bool _showJoystick = false;
  double _palitoSize = 70.0;
  Offset? _initialDragPosition;
  List<StoryAction> actions = [];
  final AudioService _audioService =
      AudioService(); // Instância do serviço de áudio

  double _narrationSpeed = 1.0;
  bool _isNarrationEnabled = false;
  DropdownOption? _selectedAction;
  final ScrollController _drawerScrollController = ScrollController();

  @override
  void dispose() {
    _audioService.dispose(); // Libera o player quando o widget for descartado
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode
          .immersiveSticky); // desativar controles do sistema (relógio, barra de status, botões de navegação)
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
    'Palito V': 'Palito V',
    'Palito H': 'Palito H',
    'Palito DD': 'Palito DD',
    'Palito DE': 'Palito DE',
    'Cima': 'Cima',
    'Baixo': 'Baixo',
    'Esquerda': 'Esquerda',
    'Direita': 'Direita',
  };

  List<DropdownOption> dropdownOptions = [
    // Movimentos
    DropdownOption(
        value: 'Cima', label: 'Saltar para Cima', type: StoryActionType.move),
    DropdownOption(
        value: 'Baixo', label: 'Saltar para Baixo', type: StoryActionType.move),
    DropdownOption(
        value: 'Esquerda',
        label: 'Saltar para Esquerda',
        type: StoryActionType.move),
    DropdownOption(
        value: 'Direita',
        label: 'Saltar para Direita',
        type: StoryActionType.move),

    // Palitos (separe com um Divider, se desejar)
    // DropdownOption(value: '-', label: '-----', type: StoryActionType.none), // Opcional: separador visual

    DropdownOption(
        value: 'Palito V',
        label: 'Palito Vertical',
        type: StoryActionType.palito),
    DropdownOption(
        value: 'Palito H',
        label: 'Palito Horizontal',
        type: StoryActionType.palito),
    DropdownOption(
        value: 'Palito DD',
        label: 'Palito Diagonal a Direita',
        type: StoryActionType.palito),
    DropdownOption(
        value: 'Palito DE',
        label: 'Palito Diagonal a Esquerda',
        type: StoryActionType.palito),
  ];

  static String _getActionLabel(String actionValue) {
    return _actionLabels[actionValue] ?? actionValue;
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
      case "Palito V":
        baseOffsetX = 40;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoVertical.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "Palito DD":
        baseOffsetX = 52;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoDiagonalDireita.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "Palito DE":
        baseOffsetX = 27;
        baseOffsetY = -25;
        if (_isNarrationEnabled) {
          await _audioService.playAudio(
            'assets/sounds/palitoDiagonalEsquerda.mp3',
            speed: _narrationSpeed,
          );
        }
        break;
      case "Palito H":
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

    if (action.palitoType == "Palito V") {
      offsetX = baseOffsetX - (sizeDiff / 10) * 5;
      offsetY = baseOffsetY - (sizeDiff / 10) * 10;
    } else if (action.palitoType == "Palito H") {
      offsetY = baseOffsetY - (sizeDiff / 10) * 5;
      offsetX = baseOffsetX;
    } else if (action.palitoType == "Palito DD") {
      offsetX = baseOffsetX - (sizeDiff / 10) * 3;
      offsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
    } else if (action.palitoType == "Palito DE") {
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

  void _addAction(int setIndex, StoryAction action) {
    setState(() {
      actionSets[setIndex]['actions'].add(action);
    });
  }

  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> actionSets = [
    {'n': 1, 'actions': <StoryAction>[]} // Conjunto inicial
  ];

  void _showCreateStoryModal(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          // title: const Center(child: Text("Selecione as ações:")),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scrollbar(
                    //   thumbVisibility: true,
                    //   controller: _scrollController,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Semantics(
                          label: 'Fechar História',
                          // button: true,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () => Navigator.pop(context),
                            tooltip:
                                "Fechar", // Mantém o tooltip para feedback visual
                          ),
                        ),
                      ],
                    ),

                    Container(
                      // Container para estilizar o SizedBox
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 67,
                                                118, 255), // Cor de fundo
                                            borderRadius: BorderRadius.circular(
                                                8), // Define o raio das bordas
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            'Ações ${i + 1}',
                                            style: const TextStyle(
                                              fontSize:
                                                  16, // Aumenta o tamanho da fonte
                                              color:
                                                  Colors.white, // Cor da fonte
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        Semantics(
                                          label:
                                              'Excluir ações do conjunto ${i + 1}', // Label semântico claro e específico
                                          button: true, // Indica que é um botão
                                          child: TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                actionSets.removeAt(i);
                                                if (actionSets.isEmpty) {
                                                  actionSets = [
                                                    {
                                                      'n': 1,
                                                      'actions': <StoryAction>[]
                                                    }
                                                  ];
                                                }
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                            ),
                                            icon: const Icon(
                                                Icons.delete_forever),
                                            label: const Text(
                                                "Excluir"), // Mantém o label visual
                                          ),
                                        ),
                                        Semantics(
                                          label:
                                              'Adicione um novo conjunto de ações', // Label semântico claro
                                          button: true, // Indica que é um botão
                                          child: TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                actionSets.add({
                                                  'n': 1,
                                                  'actions': <StoryAction>[],
                                                });
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  const Color.fromARGB(
                                                      255, 67, 118, 255),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                            ),
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            label: const Text(
                                                "Novo"), // Mantém o label visual "Novo"
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      // Container para estilizar o SizedBox
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),

                                      child: SizedBox(
                                        height:
                                            actionSets[i]['actions'].length > 2
                                                ? 100
                                                : null,
                                        child: SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              if (actionSets[i]['actions']
                                                  .isEmpty) ...[
                                                // Condição para mostrar a mensagem
                                                const Center(
                                                  // Centraliza a mensagem
                                                  child: Text('Adicione Ações'),
                                                ),
                                              ] else ...[
                                                //

                                                for (int j = 0;
                                                    j <
                                                        actionSets[i]['actions']
                                                            .length;
                                                    j++)
                                                  ListTile(
                                                    title: Text(_getActionLabel(
                                                        actionSets[i]['actions']
                                                                    [j]
                                                                .direction ??
                                                            actionSets[i][
                                                                    'actions'][j]
                                                                .palitoType ??
                                                            '')),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Semantics(
                                                          label: 'Retirar ação',
                                                          button: true,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              IconData(0x2715,
                                                                  fontFamily:
                                                                      'MaterialIcons'),
                                                              color:
                                                                  Colors.black,
                                                              size: 12,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                actionSets[i][
                                                                        'actions']
                                                                    .removeAt(
                                                                        j);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      // Row para colocar o Dropdown e o "n = " lado a lado
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,

                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: DropdownButton<DropdownOption>(
                                            hint: const Text("Selecione ações"),
                                            value: _selectedAction,
                                            onChanged:
                                                (DropdownOption? newValue) {
                                              if (newValue != null) {
                                                if (newValue.type ==
                                                    StoryActionType.move) {
                                                  final newAction = StoryAction(
                                                    type: newValue.type,
                                                    direction: newValue.value,
                                                    getActionLabel:
                                                        _getActionLabel,
                                                  );
                                                  _addAction(i,
                                                      newAction); // Chama _addAction com o índice 'i'
                                                  _moveCharacter(
                                                      newValue.value);
                                                } else if (newValue.type ==
                                                    StoryActionType.palito) {
                                                  final newAction = StoryAction(
                                                    type: newValue.type,
                                                    palitoType: newValue.value,
                                                    size: _palitoSize,
                                                    getActionLabel:
                                                        _getActionLabel,
                                                  );
                                                  _addAction(i,
                                                      newAction); // Chama _addAction com o índice 'i'
                                                  _addPalito(
                                                      newAction); // ou _addPalitoFromOption, se você a criou
                                                }
                                                setState(() {
                                                  // Atualiza o estado para refletir a mudança
                                                  _selectedAction = newValue;
                                                });
                                              }
                                            },
                                            items: dropdownOptions
                                                .map((DropdownOption option) {
                                              return DropdownMenuItem<
                                                  DropdownOption>(
                                                value: option,
                                                child: Tooltip(
                                                  message: option.label,
                                                  child: Semantics(
                                                    label: option.label,
                                                    child: Text(option.value),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Semantics(
                                              label:
                                                  'Repetir ações ${i + 1}, ${actionSets[i]['n']} vezes. Use os botões mais e menos para ajustar o número de repetições.',
                                              container:
                                                  true, // Importante: adiciona container: true
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color.fromRGBO(
                                                      84, 173, 255, 1.0),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      '  n =',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                    Semantics(
                                                      label:
                                                          'Diminuir repetições',
                                                      button: true,
                                                      child: IconButton(
                                                        iconSize:
                                                            13, // Diminui o tamanho do ícone
                                                        icon: const Icon(
                                                            Icons.remove,
                                                            color:
                                                                Colors.white),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (actionSets[i]
                                                                    ['n'] >
                                                                0) {
                                                              actionSets[i]
                                                                  ['n']--;
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Text(
                                                      '${actionSets[i]['n']}',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white),
                                                    ),
                                                    Semantics(
                                                      label:
                                                          'Aumentar repetições',
                                                      button: true,
                                                      child: IconButton(
                                                        iconSize:
                                                            13, // Diminui o tamanho do ícone

                                                        icon: const Icon(
                                                            Icons.add,
                                                            color:
                                                                Colors.white),
                                                        onPressed: () {
                                                          setState(() {
                                                            actionSets[i]
                                                                ['n']++;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     color: const Color.fromRGBO(
                                            //         84,
                                            //         173,
                                            //         255,
                                            //         1.0), // 1.0 é a opacidade (1.0 = totalmente opaco), // Cor de fundo
                                            //     borderRadius: BorderRadius.circular(
                                            //         8), // Define o raio das bordas
                                            //   ),
                                            //   // padding:
                                            //   //     const EdgeInsets.symmetric(
                                            //   //   horizontal: 4,
                                            //   //   vertical: 2,
                                            //   // ),
                                            //   child: Row(
                                            //     mainAxisSize: MainAxisSize.min,
                                            //     children: [
                                            //       const Text(
                                            //         '  n =',
                                            //         style: TextStyle(
                                            //           fontSize:
                                            //               18, // Aumenta o tamanho da fonte
                                            //           color: Colors
                                            //               .white, // Cor da fonte
                                            //         ),
                                            //       ),
                                            //       IconButton(
                                            //         iconSize:
                                            //             13, // Diminui o tamanho do ícone
                                            //         icon: const Icon(
                                            //             Icons.remove,
                                            //             color: Colors.white),
                                            //         onPressed: () {
                                            //           setState(() {
                                            //             if (actionSets[i]['n'] >
                                            //                 0) {
                                            //               actionSets[i]['n']--;
                                            //             }
                                            //           });
                                            //         },
                                            //       ),
                                            //       Text(
                                            //         '${actionSets[i]['n']}',
                                            //         style: const TextStyle(
                                            //           fontSize:
                                            //               13, // Ajuste o tamanho da fonte conforme necessário
                                            //           color: Colors.white,
                                            //         ),
                                            //       ),
                                            //       IconButton(
                                            //         iconSize:
                                            //             13, // Diminui o tamanho do ícone
                                            //         icon: const Icon(Icons.add,
                                            //             color: Colors.white),
                                            //         onPressed: () {
                                            //           setState(() {
                                            //             actionSets[i]['n']++;
                                            //           });
                                            //         },
                                            //       ),
                                            //     ],
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (i <
                                        actionSets.length -
                                            1) // Adiciona o Divider
                                      const Divider(
                                        thickness: 2,
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Text("Narração"),
                            Semantics(
                              label:
                                  'Ativar/desativar narração', // Label semântico para o Switch
                              toggled:
                                  _isNarrationEnabled, // Indica o estado do switch
                              child: Switch(
                                value: _isNarrationEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isNarrationEnabled = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Semantics(
                          label:
                              'Executar ações da história', // Label semântico para o botão
                          button: true, // Indica que é um botão
                          child: ElevatedButton(
                            onPressed: () {
                              _executeActions();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Fazer História",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   // Distribui os itens na Row
                    //   children: [
                    //     Row(
                    //       // mainAxisAlignment: MainAxisAlignment.end,
                    //       // Envolve o Switch e o Text em uma nova Row
                    //       children: [
                    //         const Text("Narração"),
                    //         Switch(
                    //           value: _isNarrationEnabled,
                    //           onChanged: (value) {
                    //             setState(() {
                    //               _isNarrationEnabled = value;
                    //             });
                    //           },
                    //         ),
                    //       ],
                    //     ),
                    //     ElevatedButton(
                    //       onPressed: () {
                    //         _executeActions();
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor:
                    //             Colors.blue, // ou outra cor adequada
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 10, vertical: 10),

                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(
                    //               8.0), // Define o raio do arredondamento
                    //         ),
                    //       ),
                    //       child: const Text(
                    //         "Fazer História",
                    //         style: TextStyle(
                    //           fontSize: 16, // Aumenta o tamanho da fonte
                    //           color: Colors.white, // Cor da fonte
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
        //     child: Scrollbar(
        // thumbVisibility: true,
        // controller: _drawerScrollController,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Semantics(
                            // Adiciona semântica para o título "Apoio"
                            // label: 'Apoio',
                            // header: true, // Indica que é um cabeçalho/título
                            child: const Text(
                              'Apoio',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                              height: 1), // Espaço entre o texto e as imagens

                          Semantics(
                            label:
                                'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva', // Descrição das imagens
                            // image: true,
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/IFSP_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    'assets/images/CNPQ_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    'assets/images/RUMO_Logo.png',
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 230,
                    child: Semantics(
                      // Adiciona o Semantics
                      label:
                          'Botão de Fechar menu', // Label semântico para o botão
                      // button: true, // Indica que é um botão
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              // dense: true,
              title: Semantics(
                label:
                    'Botões de controle de movimentos', // Descreve a função do SwitchListTile
                child: Text("Joystick"),
              ),
              value: _showJoystick,
              onChanged: (bool value) {
                setState(() {
                  _showJoystick = value;
                });
              },
              secondary: Semantics(
                label: _showJoystick
                    ? 'Joystick ativado'
                    : 'Joystick desativado', // Estado atual
                child: Icon(
                  _showJoystick ? Icons.gamepad : Icons.gamepad_outlined,
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              // dense: true,
              title: Semantics(
                label:
                    'Opção para apagar todos os palitos que estão adicionados na tela', // Descreve a ação
                button:
                    true, // Indica que o ListTile é interativo como um botão.
                child: const Text("Limpar Tela"),
              ),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  //  barrierColor: Colors.black.withOpacity(0.2),
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      title: Center(
                        child: Semantics(
                          label:
                              'Campo de Confirmação de Limpeza', // Descreve o propósito do diálogo.
                          child: const Text(
                            "Limpar Tela",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      content: const Text(
                        "Deseja remover todos os palitos da tela?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        Semantics(
                          // Torna o botão cancela acessível
                          button: true,
                          label: 'Cancelar',
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Define o raio do arredondamento
                              ),
                            ),
                            child: const Text("Cancelar"),
                          ),
                        ),
                        Semantics(
                          // Torna o botão Limpar acessível
                          button: true,
                          label:
                              'Confirmar e limpar todos os palitos', // Seja descritivo
                          child: ElevatedButton(
                            onPressed: () {
                              palitoController.clearPalitos();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Define o raio do arredondamento
                              ),
                            ),
                            child: const Text("Limpar"),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons
                  .zoom_in), // Ícone complementar, sem necessidade de Semantics.
              subtitle: Semantics(
                label:
                    'Slider para ajustar o tamanho do palito. Tamanho atual: ${_palitoSize.toStringAsFixed(0)}. Deslize para os lados para aumentar ou diminuir',
                child: Consumer<CharacterController>(
                  builder: (context, characterController, child) {
                    return Slider(
                      value: _palitoSize,
                      min: 50.0,
                      max: 120.0,
                      divisions: 7,
                      label:
                          'Tamanho do Palito', // Label visual, importante para todos os usuários
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
            ),
            ListTile(
              leading: const Icon(
                  Icons.speed), // Ícone de suporte visual, sem Semantics
              subtitle: Semantics(
                label:
                    'Slider para ajustar a velocidade da narração. Velocidade atual: ${_narrationSpeed.toStringAsFixed(1)}x. Deslize para os lados para aumentar ou diminuir', // Label semântico dinâmico
                child: Slider(
                  value: _narrationSpeed,
                  min: 0.7,
                  max: 2.0,
                  divisions: 8,
                  label:
                      'Velocidade de Narração', // Label visual para todos os usuários
                  onChanged: (double value) {
                    setState(() {
                      _narrationSpeed = value;
                      _audioService.setSpeed(_narrationSpeed);
                    });
                  },
                ),
              ),
            ),
            ListTile(
              title: Semantics(
                label: 'Quantidade de palitos na tela $_palitoCount',
                button: true, // Indica que o ListTile é interativo
                child: const Text("Contador de Palitos"),
              ),
              // dense: true,

              trailing: _showCount
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      color: const Color.fromARGB(255, 67, 118, 255),
                      child: Text(
                        '$_palitoCount',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : null, // Mostra null se _showCount for false
              onTap: () {
                setState(() {
                  _palitoCount = palitoController.palitos.length;
                  _showCount = !_showCount;
                });
              },
            ),
            ListTile(
              title: Semantics(
                label:
                    'Opção para abrir o campo de Criar história', // Label mais descritivo
                button: true, // Indica que o ListTile é um botão
                child: const Text("Criar História"),
              ),
              onTap: () {
                _showCreateStoryModal(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                return Semantics(
                  // Envolve o IconButton com Semantics
                  label:
                      'Abrir menu de navegação', // Descrição mais completa da função
                  button: true, // Indica que é um botão
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.blue),
                    tooltip:
                        "Abrir menu", // Mantém o tooltip para usuários sem deficiência visual
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // const SizedBox(height: 18),

                        MenuButton(
                          iconPath: 'assets/images/Palito V.png',
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
                            palitoController.addPalito(position, "Palito V",
                                "Palito vertical", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/Palito DD.png',
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
                            palitoController.addPalito(position, "Palito DD",
                                "Palito diagonal à direita", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/Palito DE.png',
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
                            palitoController.addPalito(position, "Palito DE",
                                "Palito diagonal à esquerda", _palitoSize);
                          },
                        ),
                        MenuButton(
                          iconPath: 'assets/images/Palito H.png',
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
                            palitoController.addPalito(position, "Palito H",
                                "Palito horizontal", _palitoSize);
                          },
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
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
                                      backgroundColor:
                                          Colors.white.withOpacity(0.8),
                                      title: const Center(
                                        // Centraliza o título do AlertDialog
                                        child: Text(
                                          "Remover Palito",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      content: const Text(
                                        "Deseja remover o palito?",
                                        textAlign: TextAlign
                                            .center, // Centraliza o conteúdo do AlertDialog
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  8.0), // Define o raio do arredondamento
                                            ),
                                          ),
                                          child: const Text("Cancelar"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            palitoController
                                                .removePalito(palito);
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  8.0), // Define o raio do arredondamento
                                            ),
                                          ),
                                          child: const Text("Remover"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.8),
                                      title: Center(
                                        child: Semantics(
                                          // Adiciona Semantics ao título
                                          // label: "Remover Palito",
                                          child: const Text(
                                            "Remover Palito",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      content: const Text(
                                        "Deseja remover o palito?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        Semantics(
                                          // Adiciona Semantics ao botão "Cancelar"
                                          label: 'Cancelar',
                                          button: true,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: const Text("Cancelar"),
                                          ),
                                        ),
                                        Semantics(
                                          // Adiciona Semantics ao botão "Remover"
                                          label: 'Remover',
                                          button: true,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              palitoController
                                                  .removePalito(palito);
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: const Text("Remover"),
                                          ),
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
                          const SizedBox(width: 1),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              JoystickButton(
                                icon: Icons.arrow_drop_up,
                                onPressed: () => controller.moveUp(),
                                tooltip: "Mover para cima",
                                semanticsLabel: "Botão de direção: cima",
                              ),
                              const SizedBox(height: 10),
                              JoystickButton(
                                icon: Icons.arrow_drop_down,
                                onPressed: () => controller.moveDown(),
                                tooltip: "Mover para baixo",
                                semanticsLabel: "Botão de direção: baixo",
                              ),
                            ],
                          ),
                          const SizedBox(width: 1),
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
          ],
        ),
      ),
    );
  }
}
