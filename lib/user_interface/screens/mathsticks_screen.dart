import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/character_service.dart';
import '../../services/palito_service.dart';
import '../widgets/joystick_button.dart';
import '../widgets/menu_button.dart';
import '../../data/story_action.dart';
import '../../services/audio_service.dart';
import 'package:flutter/services.dart';
import 'instruction_screen.dart';
import 'tanks_screen.dart';

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
  bool _showJoystick = true;
  double _palitoSize = 70.0;
  Offset? _initialDragPosition;
  List<StoryAction> actions = [];
  final AudioService _audioService = AudioService();
  double _narrationSpeed = 1.0;
  bool _isNarrationEnabled = false;
  DropdownOption? _selectedAction;
  final ScrollController _drawerScrollController = ScrollController();
  int _palitoCount = 0;
  bool _showCount = false;
  final ScrollController _scrollController = ScrollController();
  bool _executingStory = false;

  @override
  void dispose() {
    _audioService.dispose();
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void updateStepSize() {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    setState(() {
      characterController.setStepSize(_palitoSize);
    });
  }

  void announceForAccessibility(String message, BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        child: Semantics(
          label: message,
          liveRegion: true,
          container: true,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  Future<void> _executeActions() async {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    final palitoController =
        Provider.of<PalitoController>(context, listen: false);
    characterController.isHistoryMode = true;
    _executingStory = true;

    bool borderAlertShown =
        false; 

    for (final actionSet in actionSets) {
      int repeatCount = actionSet['n'] as int;
      List<StoryAction> actions = actionSet['actions'] as List<StoryAction>;
      for (int i = 0; i < repeatCount; i++) {
        for (StoryAction action in actions) {
          if (!_executingStory) break;

          
          if (characterController.isAtAnyBorder() && !borderAlertShown) {
            stopStory();
            String borderMessage =
                characterController.getBorderHit(); 
            WidgetsBinding.instance.addPostFrameCallback((_) {
             
              announceForAccessibility(borderMessage, context);

             
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(borderMessage),
                ),
              );
            });
            borderAlertShown = true; 
            return; 
          }
          borderAlertShown = false;

         
          bool anyPalitoOffscreen = false;
          for (Palito palito in palitoController.palitos) {
            if (palito.isPartiallyOffscreen(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height, context)) {
              anyPalitoOffscreen = true;
              break;
            }
          }

          if (anyPalitoOffscreen) {
            stopStory();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Semantics(
                    label: 'Alerta: Palito fora da tela.',
                    child: const Text(
                      "Um palito está parcialmente fora da tela. A história foi interrompida.",
                    ),
                  ),
                ),
              );
            });
            return;
          }

          if (action.type == StoryActionType.move) {
            await _moveCharacter(action.direction!);
          } else {
            await _addPalito(context, action);
          }
          await Future.delayed(
            _isNarrationEnabled
                ? const Duration(milliseconds: 1600)
                : const Duration(milliseconds: 100),
          );
        }
        if (!_executingStory) break;
      }
      if (!_executingStory) break;
    }
    characterController.isHistoryMode = false;
    _executingStory = false;
  }

  void stopStory() {
    setState(() {
      _executingStory = false;
      _audioService.stopAudio();
    });
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
        label: 'Palito Diagonal à Direita',
        type: StoryActionType.palito),
    DropdownOption(
        value: 'Palito DE',
        label: 'Palito Diagonal à Esquerda',
        type: StoryActionType.palito),
  ];

  static String _getActionLabel(String actionValue) {
    return _actionLabels[actionValue] ?? actionValue;
  }

  Future<void> _moveCharacter(String direction) async {
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
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

  Future<void> _addPalito(BuildContext context, StoryAction action) async {
    final palitoController =
        Provider.of<PalitoController>(context, listen: false);
    final characterController =
        Provider.of<CharacterController>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ignore: unused_local_variable
    const double baseSize = 50;
    // ignore: unused_local_variable
    double baseOffsetX = 0, baseOffsetY = 0;

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

    final sizeDiff = _palitoSize - 50;
    double offsetX = 0, offsetY = 0;

    switch (action.palitoType) {
      case "Palito V":
        offsetX = 40 - (sizeDiff / 10) * 5;
        offsetY = -25 - (sizeDiff / 10) * 10;
        break;
      case "Palito H":
        offsetY = -2 - (sizeDiff / 10) * 5;
        offsetX = 65;
        break;
      case "Palito DD":
        offsetX = 52 - (sizeDiff / 10) * 3;
        offsetY = -25 - (sizeDiff / 10) * 9.5;
        break;
      case "Palito DE":
        offsetX = 27 - (sizeDiff / 10) * 6;
        offsetY = -25 - (sizeDiff / 10) * 9.5;
        break;
    }

    final position = Offset(
      characterController.xPosition + offsetX,
      characterController.yPosition + offsetY,
    );

    Palito tempPalito = Palito(
        position: position,
        type: action.palitoType!,
        semanticsLabel: action.palitoType!,
        size: _palitoSize);

    if (tempPalito.isPartiallyOffscreen(screenWidth, screenHeight, context)) {
      // if (!_isNarrationEnabled && !_palitoOffscreenAlertShown) {
      // if (!_isNarrationEnabled) {
      // _palitoOffscreenAlertShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        stopStory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Semantics(
              label: 'Alerta: Palito fora da tela.',
              child: const Text(
                "Não é possível adicionar um Palito fora da tela. Diminua o tamanho ou mude a posição.",
              ),
            ),
          ),
        );
      });
      // }
      return; 
    } else {
      // _palitoOffscreenAlertShown = false;
    }
    palitoController.addPalito(
        position, action.palitoType!, action.palitoType!, _palitoSize);
  }

  void _addAction(int setIndex, StoryAction action) {
    setState(() {
      actionSets[setIndex]['actions'].add(action);
    });
  }

  List<Map<String, dynamic>> actionSets = [
    {'n': 1, 'actions': <StoryAction>[]}
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
                            tooltip: "Fechar",
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        height: actions.length > 2 ? 100 : null,
                        child: SingleChildScrollView(
                          // thumbVisibility: true,
                          controller: _scrollController,
                          child: Column(
                            children: [
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
                                            color: const Color.fromARGB(
                                                255, 67, 118, 255),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            'Ações ${i + 1}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        Semantics(
                                          label:
                                              'Excluir ações do conjunto ${i + 1}',
                                          button: true,
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
                                            label: const Text("Excluir"),
                                          ),
                                        ),
                                        Semantics(
                                          label:
                                              'Adicione um novo conjunto de ações',
                                          button: true,
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
                                            label: const Text("Novo"),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
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
                                                const Center(
                                                  child: Text('Adicione Ações'),
                                                ),
                                              ] else ...[
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
                                                              Icons
                                                                  .delete_forever,
                                                              color: Colors.red,
                                                              size: 20,
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
                                                  _addAction(i, newAction);
                                                  _moveCharacter(
                                                      newValue.value);
                                                } else if (newValue.type ==
                                                    StoryActionType.palito) {
                                                  final newAction = StoryAction(
                                                    type: newValue.type,
                                                    palitoType: newValue.value,
                                                    getActionLabel:
                                                        _getActionLabel,
                                                  );
                                                  _addAction(i, newAction);
                                                  _addPalito(
                                                      context, newAction);
                                                }
                                                setState(() {
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
                                              container: true,
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
                                                        iconSize: 13,
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
                                                        iconSize: 13,
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
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (i < actionSets.length - 1)
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
                              label: 'Ativar/desativar narração',
                              toggled: _isNarrationEnabled,
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
                          label: 'Executar ações da história',
                          button: true,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final characterController =
            Provider.of<CharacterController>(context, listen: false);
        final palitoController =
            Provider.of<PalitoController>(context, listen: false);

        characterController.setScreenSize(screenWidth, screenHeight);

        final controller =
            Provider.of<CharacterController>(context, listen: false);

        controller.setScreenSize(screenWidth, screenHeight);

        return Scaffold(
          body: Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color.fromRGBO(220, 247, 255, 1.0),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Builder(
                  builder: (context) {
                    return Semantics(
                      label: 'Abrir menu de navegação',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.blue),
                        tooltip: "Abrir menu",
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
                      Consumer<PalitoController>(
                        builder: (context, palitoController, child) {
                          palitoController.checkAllPalitosOffscreen(
                            context,
                            screenWidth,
                            screenHeight,
                          );
                          return Stack(
                            children: palitoController.palitos.map((palito) {
                              final wrappedPosition = palito.getWrappedPosition(
                                  screenWidth, screenHeight);
                              return Positioned(
                                top: wrappedPosition.dy +
                                    MediaQuery.of(context).padding.top,
                                left: wrappedPosition.dx,
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.8),
                                          title: Center(
                                            child: Semantics(
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
                                              label: 'Cancelar',
                                              button: true,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: const Text("Cancelar"),
                                              ),
                                            ),
                                            Semantics(
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
                                                        BorderRadius.circular(
                                                            8.0),
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
                                    button: false,
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
                          // if (controller.borderAlert != null) {
                          //   WidgetsBinding.instance.addPostFrameCallback((_) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //           content: Text(controller.borderAlert!)),
                          //     );
                          //   });
                          // }
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
                                    if (dragDelta.dx.abs() >
                                        dragDelta.dy.abs()) {
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
                                    _initialDragPosition =
                                        details.globalPosition;
                                  }
                                }
                              },
                              child: Semantics(
                                label: 'Personagem',
                                image: true,
                                child: Image.asset(
                                  'assets/images/personagem.png',
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // const SizedBox(height: 18),
                            MenuButton(
                              iconPath: 'assets/images/Palito V.png',
                              label: "Palito V",
                              tooltip: "Adicionar palito vertical",
                              semanticsLabel: "Palito Vertical",
                              onTap: () {
                                final characterController =
                                    Provider.of<CharacterController>(context,
                                        listen: false);
                                final palitoController =
                                    Provider.of<PalitoController>(context,
                                        listen: false);
                                const double baseSize = 50;
                                double baseOffsetX = 40;
                                double baseOffsetY = -25;
                                final sizeDiff = _palitoSize - baseSize;
                                final offsetX =
                                    baseOffsetX - (sizeDiff / 10) * 5;
                                final offsetY =
                                    baseOffsetY - (sizeDiff / 10) * 10;

                                Offset position = Offset(
                                  characterController.xPosition + offsetX,
                                  characterController.yPosition + offsetY,
                                );
                                Palito tempPalito = Palito(
                                    position: position,
                                    type: "Palito V",
                                    semanticsLabel: "Palito vertical",
                                    size: _palitoSize);
                                if (tempPalito.isPartiallyOffscreen(
                                    screenWidth, screenHeight, context)) {
                                  // if (!_isNarrationEnabled && !_palitoOffscreenAlertShown) {
                                  if (!_isNarrationEnabled) {
                                    // _palitoOffscreenAlertShown = true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Semantics(
                                          label: 'Alerta: Palito fora da tela.',
                                          child: const Text(
                                            "Não é possível adicionar um Palito fora da tela. Diminua o tamanho ou mude a posição.",
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                } else {
                                  // _palitoOffscreenAlertShown = false;
                                }
                                palitoController.addPalito(position, "Palito V",
                                    "Palito vertical", _palitoSize);
                              },
                            ),

                            MenuButton(
                              iconPath: 'assets/images/Palito DD.png',
                              label: "Palito DD",
                              tooltip: "Adicionar palito diagonal à direita",
                              semanticsLabel: "Palito Diagonal à Direita",
                              onTap: () {
                                final characterController =
                                    Provider.of<CharacterController>(context,
                                        listen: false);
                                final palitoController =
                                    Provider.of<PalitoController>(context,
                                        listen: false);

                                const double baseSize = 50;
                                double baseOffsetX = 52;
                                double baseOffsetY = -25;

                                final sizeDiff = _palitoSize - baseSize;
                                final offsetX =
                                    baseOffsetX - (sizeDiff / 10) * 3;
                                final offsetY =
                                    baseOffsetY - (sizeDiff / 10) * 9.5;

                                final Offset position = Offset(
                                  characterController.xPosition + offsetX,
                                  characterController.yPosition + offsetY,
                                );

                                Palito tempPalito = Palito(
                                    position: position,
                                    type: "Palito DD",
                                    semanticsLabel: "Palito Diagonal à Direita",
                                    size: _palitoSize);

                                if (tempPalito.isPartiallyOffscreen(
                                    screenWidth, screenHeight, context)) {
                                  // if (!_isNarrationEnabled && !_palitoOffscreenAlertShown) {
                                  if (!_isNarrationEnabled) {
                                    // _palitoOffscreenAlertShown = true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Semantics(
                                          label: 'Alerta: Palito fora da tela.',
                                          child: const Text(
                                            "Não é possível adicionar um Palito fora da tela. Diminua o tamanho ou mude a posição.",
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                } else {
                                  // _palitoOffscreenAlertShown = false;
                                }

                                palitoController.addPalito(
                                    position,
                                    "Palito DD",
                                    "Palito Diagonal à Direita",
                                    _palitoSize);
                              },
                            ),
                            MenuButton(
                              iconPath: 'assets/images/Palito DE.png',
                              label: "Palito DE",
                              tooltip: "Adicionar palito diagonal à esquerda",
                              semanticsLabel: "Palito Diagonal à Esquerda",
                              onTap: () {
                                final characterController =
                                    Provider.of<CharacterController>(context,
                                        listen: false);
                                final palitoController =
                                    Provider.of<PalitoController>(context,
                                        listen: false);

                                const double baseSize = 50;
                                double baseOffsetX = 27;
                                double baseOffsetY = -25;

                                final sizeDiff = _palitoSize - baseSize;
                                final offsetX =
                                    baseOffsetX - (sizeDiff / 10) * 6;
                                final offsetY =
                                    baseOffsetY - (sizeDiff / 10) * 9.5;

                                final Offset position = Offset(
                                  characterController.xPosition + offsetX,
                                  characterController.yPosition + offsetY,
                                );

                                Palito tempPalito = Palito(
                                    position: position,
                                    type: "Palito DE",
                                    semanticsLabel:
                                        "Palito Diagonal à Esquerda",
                                    size: _palitoSize);
                                if (tempPalito.isPartiallyOffscreen(
                                    screenWidth, screenHeight, context)) {
                                  // if (!_isNarrationEnabled && !_palitoOffscreenAlertShown) {
                                  if (!_isNarrationEnabled) {
                                    // _palitoOffscreenAlertShown = true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Semantics(
                                          label: 'Alerta: Palito fora da tela.',
                                          child: const Text(
                                            "Não é possível adicionar um Palito fora da tela. Diminua o tamanho ou mude a posição.",
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                } else {
                                  // _palitoOffscreenAlertShown = false;
                                }

                                palitoController.addPalito(
                                    position,
                                    "Palito DE",
                                    "Palito Diagonal à Esquerda",
                                    _palitoSize);
                              },
                            ),
                            MenuButton(
                              iconPath: 'assets/images/Palito H.png',
                              label: "Palito H",
                              tooltip: "Adicionar palito horizontal",
                              semanticsLabel: "Palito Horizontal",
                              onTap: () {
                                final characterController =
                                    Provider.of<CharacterController>(context,
                                        listen: false);
                                final palitoController =
                                    Provider.of<PalitoController>(context,
                                        listen: false);

                                const double baseSize = 50;
                                double baseOffsetX = 65;
                                double baseOffsetY = -2;
                                final sizeDiff = _palitoSize - baseSize;
                                final offsetY =
                                    baseOffsetY - (sizeDiff / 10) * 5;
                                final Offset position = Offset(
                                  characterController.xPosition + baseOffsetX,
                                  characterController.yPosition + offsetY,
                                );
                                Palito tempPalito = Palito(
                                    position: position,
                                    type: "Palito H",
                                    semanticsLabel: "Palito Horizontal",
                                    size: _palitoSize);

                                if (tempPalito.isPartiallyOffscreen(
                                    screenWidth, screenHeight, context)) {
                                  // if (!_isNarrationEnabled && !_palitoOffscreenAlertShown) {
                                  if (!_isNarrationEnabled) {
                                    // _palitoOffscreenAlertShown = true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Semantics(
                                          label: 'Alerta: Palito fora da tela.',
                                          child: const Text(
                                            "Não é possível adicionar um Palito fora da tela. Diminua o tamanho ou mude a posição.",
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                } else {
                                  // _palitoOffscreenAlertShown = false;
                                }

                                palitoController.addPalito(position, "Palito H",
                                    "Palito Horizontal", _palitoSize);
                              },
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
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
                                tooltip: "Saltar para esquerda",
                                semanticsLabel: "Saltar para esquerda",
                              ),
                              const SizedBox(width: 1),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  JoystickButton(
                                    icon: Icons.arrow_drop_up,
                                    onPressed: () => controller.moveUp(),
                                    tooltip: "Saltar para cima",
                                    semanticsLabel: "Saltar para cima",
                                  ),
                                  const SizedBox(height: 10),
                                  JoystickButton(
                                    icon: Icons.arrow_drop_down,
                                    onPressed: () => controller.moveDown(),
                                    tooltip: "Saltar para baixo",
                                    semanticsLabel: "Saltar para baixo",
                                  ),
                                ],
                              ),
                              const SizedBox(width: 1),
                              JoystickButton(
                                icon: Icons.arrow_right,
                                onPressed: () => controller.moveRight(),
                                tooltip: "Saltar para direita",
                                semanticsLabel: "Saltar para direita",
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
          drawer: Drawer(
            //     child: Scrollbar(
            // thumbVisibility: true,
            // controller: _drawerScrollController,
            child: ListView(
              // padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Semantics(
                              // label: 'Apoio',
                              // header: true,
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
                            const SizedBox(height: 1),
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
                      Positioned(
                        bottom: 100,
                        left: 230,
                        child: Semantics(
                          label: 'Botão de Fechar menu',
                          // button: true,
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
                ListTile(
                  title: Semantics(
                    label: 'Remover todos os palitos da tela',
                    button: true,
                    child: const Text("Limpar Tela"),
                  ),
                  leading: const Icon(Icons.delete, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(context);
                    palitoController.clearPalitos();
                  },
                ),
                SwitchListTile(
                  title: Semantics(
                    label: 'Botões de controle de movimentos',
                    child: const Text("Joystick"),
                  ),
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
                  leading: const Icon(Icons.format_size, color: Colors.blue),
                  subtitle: Semantics(
                    label:
                        'Ajustar o tamanho do palito. Arraste para os lados para aumentar ou diminuir. Tamanho atual do palito: ${_palitoSize.toStringAsFixed(0)}',
                    child: Consumer<CharacterController>(
                      builder: (context, characterController, child) {
                        return ExcludeSemantics(
                          child: Slider(
                            value: _palitoSize,
                            min: 50.0,
                            max: 120.0,
                            divisions: 7,
                            label: 'Tamanho do Palito',
                            onChanged: (double value) {
                              setState(() {
                                _palitoSize = value;
                                characterController.setStepSize(value);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.blue),
                  subtitle: Semantics(
                    label:
                        'Ajustar a velocidade da narração. Arraste para os lados para aumentar ou diminuir. Velocidade atual: ${_narrationSpeed.toStringAsFixed(1)}x.',
                    child: Consumer<CharacterController>(
                      builder: (context, characterController, child) {
                        return ExcludeSemantics(
                          child: Slider(
                            value: _narrationSpeed,
                            min: 0.7,
                            max: 2.0,
                            divisions: 8,
                            label: 'Velocidade de Narração',
                            onChanged: (double value) {
                              setState(() {
                                _narrationSpeed = value;
                                _audioService.setSpeed(_narrationSpeed);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.numbers, color: Colors.blue),
                  title: Semantics(
                    label: 'Quantidade de palitos na tela $_palitoCount',
                    button: true,
                    child: const Text("Contador de Palitos"),
                  ),
                  // dense: true,

                  trailing: _showCount
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          color: const Color.fromARGB(255, 67, 118, 255),
                          child: Text(
                            '$_palitoCount',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _palitoCount = palitoController.palitos.length;
                      _showCount = !_showCount;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir o campo de Criar história',
                    // button: true,

                    child: const Text("Criar História"),
                  ),
                  onTap: () {
                    _showCreateStoryModal(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir a página de instruções de uso',
                    // button: true,

                    child: const Text("Instruções de Uso"),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InstructionsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.handshake, color: Colors.blue),
                  title: Semantics(
                    label: 'Abrir a página de agradecimentos',
                    // button: true,

                    child: const Text("Agradecimentos"),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ThankYouScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
