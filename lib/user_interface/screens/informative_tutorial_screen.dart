import 'package:flutter/material.dart';
import 'package:mathsticks/user_interface/screens/mathsticks_screen.dart';
import 'package:provider/provider.dart';
import '../../../services/character_service.dart';
import '../../../services/tutorial_service.dart';
import '../widgets/informative_tutorial_ui.dart';
import '../../../services/palito_service.dart';
import 'package:flutter/services.dart';
import '../widgets/vlibras_widget.dart';

class InfoStep {
  final GlobalKey? targetKey;
  final String Function(BuildContext) getInstruction;
  final Widget? customHighlight;
  final bool isActionStep;
  final VoidCallback? onStepEnter;

  InfoStep({
    this.targetKey,
    required this.getInstruction,
    this.customHighlight,
    this.isActionStep = false,
    this.onStepEnter,
  });
}

class InformativeTutorialScreen extends StatefulWidget {
  const InformativeTutorialScreen({super.key});

  @override
  _InformativeTutorialScreenState createState() =>
      _InformativeTutorialScreenState();
}

class _InformativeTutorialScreenState extends State<InformativeTutorialScreen> {
  final TutorialService _tutorialService = TutorialService();
  int _currentStepIndex = 0;
  OverlayEntry? _overlayEntry;

  final GlobalKey _keyGrid = GlobalKey();
  final GlobalKey _keyPalitoButtons = GlobalKey();
  final GlobalKey _keyJoystick = GlobalKey();
  final GlobalKey _keyCharacter = GlobalKey();
  final GlobalKey _keyAutoJumpToggle = GlobalKey();
  final GlobalKey _keyPalitoV = GlobalKey();
  final GlobalKey _keyPalitoDD = GlobalKey();
  final GlobalKey _keyPalitoDE = GlobalKey();
  final GlobalKey _keyPalitoH = GlobalKey();
  final GlobalKey _keyJumpUp = GlobalKey();
  final GlobalKey _keyJumpDown = GlobalKey();
  final GlobalKey _keyJumpLeft = GlobalKey();
  final GlobalKey _keyJumpRight = GlobalKey();

  final FocusNode _instructionFocusNode = FocusNode();
  bool _isAutoJumpEnabled = false;
  List<InfoStep> _tutorialSteps = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetContext();
      _setupSteps();
      // Espera o primeiro layout para desenhar o destaque
      _showHighlight();
    });
  }

  void _resetContext() {
    Provider.of<PalitoController>(context, listen: false).clearPalitos();
    _isAutoJumpEnabled = false;
    final ctrl = Provider.of<CharacterController>(context, listen: false);
    final size = MediaQuery.of(context).size;
    ctrl.setStepSize(70.0);
    ctrl.setScreenSize(size.width, size.height);
    ctrl.resetPosition();
  }

  void _setupSteps() {
    _tutorialSteps = [
      // 1. INTRODUÇÃO
      InfoStep(
        getInstruction: (_) =>
            'Ative o VLibras no ícone à direita, depois toque em "Avançar" ou apenas em "Avançar" para seguir sem a tradução.',
      ),
      InfoStep(
        getInstruction: (_) =>
            'Bem-vindo ao Mathsticks! Sua tela é dividida em uma grade com linhas e colunas.',
      ),
      InfoStep(
        getInstruction: (_) =>
            'As colunas são organizadas em ordem alfabética da esquerda para direita, e as linhas em ordem numérica de cima para baixo.',
      ),
      InfoStep(
        targetKey: _keyCharacter,
        getInstruction: (_) =>
            'O personagem pássaro é seu ponto de referência para adicionar os palitos.',
      ),
      InfoStep(
        targetKey: _keyPalitoButtons,
        getInstruction: (_) =>
            'Para adicionar os palitos na tela, use os ícones no canto superior esquerdo.',
      ),
      InfoStep(
        targetKey: _keyJoystick,
        getInstruction: (_) =>
            'Para mover o personagem use os ícones de salto, chamado de Joystick.',
      ),
      

      // 2. PRÁTICA MANUAL
      InfoStep(
        getInstruction: (_) =>
            'Vamos praticar desenhando um quadrado!',
        onStepEnter: _resetContext,
      ),
      InfoStep(
        targetKey: _keyPalitoH,
        isActionStep: true,
        getInstruction: (_) => 'Comece adicionando um Palito Horizontal.',
      ),
      InfoStep(
        targetKey: _keyPalitoV,
        isActionStep: true,
        getInstruction: (_) => 'Adicione um Palito Vertical.',
      ),
      InfoStep(
        targetKey: _keyJumpRight,
        isActionStep: true,
        getInstruction: (_) => 'Agora mova o personagem clicando no ícone Saltar Para Direita.',
      ),
      InfoStep(
        targetKey: _keyPalitoV,
        isActionStep: true,
        getInstruction: (_) => 'Adicione mais um Palito Vertical.',
      ),
      InfoStep(
        targetKey: _keyJumpUp,
        isActionStep: true,
        getInstruction: (_) => 'Agora, mova o personagem no botao Saltar Para cima.',
      ),
      InfoStep(
        targetKey: _keyJumpLeft,
        isActionStep: true,
        getInstruction: (_) => 'Mova o personagem no ícone Saltar Para Esquerda.',
      ),
      InfoStep(
        targetKey: _keyPalitoH,
        isActionStep: true,
        getInstruction: (_) => 'Para fechar o quadrado, adicione um Palito Horizontal.',
      ),
      InfoStep(
        targetKey: _keyAutoJumpToggle,
        getInstruction: (_) =>
            'Na parte superior central da tela está o ícone de "Salto Automático". Quando ativado, sempre que um novo palito for adicionado, o personagem saltará automaticamente para a próxima posição',
         onStepEnter: _resetContext,
     
      ),
      InfoStep(
        targetKey: _keyAutoJumpToggle,
        isActionStep: true,
        getInstruction: (_) => 'Agora, ative Salto Automático para testá-lo.',
       
      ),
      InfoStep(
        targetKey: _keyPalitoH,
        isActionStep: true,
        getInstruction: (_) => 'Adicione um Palito Horizontal. O personagem saltará sozinho!',
      ),
      InfoStep(
        targetKey: _keyPalitoV,
        isActionStep: true,
        getInstruction: (_) => 'Ele deu um salto para a direita! Agora adicione um Palito Vertical.',
      ),
      InfoStep(
        targetKey: _keyJumpLeft,
        isActionStep: true,
        getInstruction: (_) => 'Mova o personagem no ícone Saltar Para Esquerda.',
      ),
      InfoStep(
        targetKey: _keyJumpDown,
        isActionStep: true,
        getInstruction: (_) => 'Agora, mova o personagem no ícone Saltar Para Baixo.',
      ),
      InfoStep(
        targetKey: _keyPalitoV,
        isActionStep: true,
        getInstruction: (_) => 'Adicione outro Palito Vertical e ele também saltará para cima.',
      ),
      InfoStep(
        targetKey: _keyPalitoH,
        isActionStep: true,
        getInstruction: (_) => 'Para finalizar o exercício, adicione um Palito Horizontal.',
      ),

      // 4. FINALIZAÇÃO
      InfoStep(
        getInstruction: (_) =>
            'Tutorial Finalizado!',
      ),
    ];
  }

  // Define se o joystick deve ir para a esquerda
  bool _shouldMoveJoystickToLeft(GlobalKey? key) {
    if (key == null) return false;
    return key == _keyJumpUp ||
        key == _keyJumpDown ||
        key == _keyJumpLeft ||
        key == _keyJumpRight || 
        key == _keyJoystick;
  }

  void _nextStep() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_currentStepIndex < _tutorialSteps.length - 1) {
        // 1. Remove o highlight antigo imediatamente para não ficar "fantasma"
        _removeHighlight();
        
        setState(() {
          _currentStepIndex++;
          final nextStep = _tutorialSteps[_currentStepIndex];
          if (nextStep.onStepEnter != null) {
            nextStep.onStepEnter!();
          }
        });

        // 2. CORREÇÃO PRINCIPAL: Espera o layout atualizar (joystick mover) antes de calcular a nova posição
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showHighlight();
        });
      } else {
        _finishTutorial();
      }
    });
  }

void _showHighlight() {
    _removeHighlight();
    if (_currentStepIndex >= _tutorialSteps.length) return;

    final step = _tutorialSteps[_currentStepIndex];
    final String baseInstruction = step.getInstruction(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      VLibrasWidget.buscarTraducao(baseInstruction);
    });
    
    if (step.targetKey != null && step.targetKey!.currentContext == null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _showHighlight();
      });
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        
        final double fontSize = (screenSize.width * 0.025).clamp(16.0, 24.0);
        final double btnFontSize = (screenSize.width * 0.022).clamp(16.0, 24.0);
        
        Rect highlightRect = Rect.zero;
        if (step.targetKey?.currentContext != null) {
          final renderBox = step.targetKey!.currentContext!.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);
          highlightRect = Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height).inflate(8.0);
        }

        final bool isLastStep = _currentStepIndex == _tutorialSteps.length - 1;
        String semanticLabel = baseInstruction;
        if (isLastStep) {
          semanticLabel = '$baseInstruction. Clique no botão concluir.';
        } else if (!step.isActionStep) {
          semanticLabel = '$baseInstruction. Clique no botão avançar para continuar.';
        }

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children:[
              if (step.targetKey != null)
                Positioned.fromRect(
                  rect: highlightRect,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellowAccent, width: 4),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:[
                          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)
                        ]
                      ),
                    ),
                  ),
                ),
              
              if (step.customHighlight != null)
                IgnorePointer(ignoring: true, child: step.customHighlight!),

              // CAIXA DE TEXTO COM TAMANHO AJUSTÁVEL E POSIÇÃO INTELIGENTE
              Builder(
                builder: (ctx) {
                  Alignment boxAlignment;
                  EdgeInsets boxMargin;

                  // Lógica de posição
                  if (isLastStep) {
                    // SE FOR A ÚLTIMA TELA (TUTORIAL COMPLETO), FICA NO CENTRO ABSOLUTO
                    boxAlignment = Alignment.center;
                    boxMargin = EdgeInsets.zero;
                  } else if (step.targetKey == _keyPalitoButtons || 
                      step.targetKey == _keyPalitoV || 
                      step.targetKey == _keyPalitoDD || 
                      step.targetKey == _keyPalitoDE || 
                      step.targetKey == _keyPalitoH) {
                    boxAlignment = Alignment.topCenter;
                    boxMargin = const EdgeInsets.only(top: 20.0);
                  } else if (step.targetKey == _keyAutoJumpToggle) {
                    boxAlignment = Alignment.bottomLeft;
                    boxMargin = const EdgeInsets.only(left: 20.0, bottom: 20.0);
                  } else {
                    boxAlignment = Alignment.topLeft;
                    boxMargin = const EdgeInsets.only(left: 20.0, top: 20.0);
                  }

                  return Positioned.fill(
                    child: Align(
                      alignment: boxAlignment,
                      child: Padding(
                        padding: boxMargin,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: screenSize.width * 0.55),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2)
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, 
                            children:[
                              Focus(
                                focusNode: _instructionFocusNode,
                                child: Semantics(
                                  liveRegion: true,
                                  label: semanticLabel,
                                  child: ExcludeSemantics(
                                    child: Text(
                                      baseInstruction,
                                      style: TextStyle(
                                        color: Colors.blueAccent, 
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // USO DE WRAP PARA GARANTIR CENTRALIZAÇÃO DOS BOTÕES
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16.0, // Espaço entre os botões
                                runSpacing: 8.0,
                                children:[
                                  if (!isLastStep)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onPressed: _finishTutorial,
                                      child: Text(
                                        'Pular Tutorial',
                                        style: TextStyle(fontSize: btnFontSize * 0.8, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  if (!step.isActionStep)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        textStyle: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: isLastStep ? _finishTutorial : _nextStep,
                                      child: Text(isLastStep ? 'Concluir' : 'Avançar'),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _instructionFocusNode.canRequestFocus) {
        _instructionFocusNode.requestFocus();
      }
    });
  }


  void _removeHighlight() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _finishTutorial() async {
    _removeHighlight();
    await _tutorialService.completeInformativeTutorial();
    await _tutorialService.completePracticalTutorial();

    if (!mounted) return;
    
    Provider.of<PalitoController>(context, listen: false).clearPalitos();
    Provider.of<CharacterController>(context, listen: false).resetPosition();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Mathsticks()),
    );
  }

  void _handleAction(GlobalKey key) {
    if (!mounted || _currentStepIndex >= _tutorialSteps.length) return;
    final step = _tutorialSteps[_currentStepIndex];
    if (step.isActionStep && step.targetKey == key) {
      _nextStep();
    }
  }

  // --- Callbacks de Ação ---
  void _onPalitoVTapped() {
    _addPalito('Palito V', 'Palito Vertical');
    _handleAction(_keyPalitoV);
  }
  void _onPalitoDDTapped() {
    _addPalito('Palito DD', 'Palito Diagonal à Direita');
    _handleAction(_keyPalitoDD);
  }
  void _onPalitoDETapped() {
    _addPalito('Palito DE', 'Palito Diagonal à Esquerda');
    _handleAction(_keyPalitoDE);
  }
  void _onPalitoHTapped() {
    _addPalito('Palito H', 'Palito Horizontal');
    _handleAction(_keyPalitoH);
  }

  void _addPalito(String type, String label) {
    final characterCtrl = Provider.of<CharacterController>(context, listen: false);
    final palitoCtrl = Provider.of<PalitoController>(context, listen: false);
    
    final pos = palitoCtrl.getPositionForNewPalito(
        type, 
        Offset(characterCtrl.xPosition, characterCtrl.yPosition), 
        characterCtrl.characterSize
    );
    
    palitoCtrl.addPalito(pos, type, label, characterCtrl.characterSize);

    if (_isAutoJumpEnabled) {
       switch (type) {
        case 'Palito V': characterCtrl.moveUp(); break;
        case 'Palito H': 
        case 'Palito DD': characterCtrl.moveRight(); break;
      }
    }
  }

  @override
  void dispose() {
    _removeHighlight();
    _instructionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    // 1. Qual o passo atual?
    final GlobalKey? currentStepKey = (_tutorialSteps.isNotEmpty && _currentStepIndex < _tutorialSteps.length)
        ? _tutorialSteps[_currentStepIndex].targetKey
        : null;
        
    final bool isAutoJumpActionStep = (_tutorialSteps.isNotEmpty && _currentStepIndex < _tutorialSteps.length) &&
        _tutorialSteps[_currentStepIndex].isActionStep &&
        _tutorialSteps[_currentStepIndex].targetKey == _keyAutoJumpToggle;

     //final bool isAutoJumpEnabledInThisStep = isAutoJumpActionStep; 
    
    // 2. Decide se o joystick deve estar na ESQUERDA com base no passo atual
    final bool moveJoystickLeft = _shouldMoveJoystickToLeft(currentStepKey);

    return Scaffold(
      backgroundColor: const Color(0xFFDCF7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Salto Automático',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
                Switch(
  key: _keyAutoJumpToggle,
  value: _isAutoJumpEnabled,
  activeColor: Colors.blue,

  // ✅ Só fica clicável no passo: "Agora, ative Salto Automático para testá-lo."
  onChanged: isAutoJumpActionStep
      ? (value) {
          setState(() => _isAutoJumpEnabled = value);

          // como é um passo de ação, avançar ao interagir
          _handleAction(_keyAutoJumpToggle);
        }
      : null, // 🔒 desabilita no passo informativo
),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Interface Principal
          Column(
            children: [
              Expanded(
                child: InformativeTutorialUI(
                  keyGrid: _keyGrid,
                  keyPalitoButtons: _keyPalitoButtons,
                  keyJoystick: _keyJoystick,
                  keyCharacter: _keyCharacter,
                  keyAutoJumpToggle: _keyAutoJumpToggle,
                  keyPalitoV: _keyPalitoV,
                  keyPalitoDD: _keyPalitoDD,
                  keyPalitoDE: _keyPalitoDE,
                  keyPalitoH: _keyPalitoH,
                  keyJumpUp: _keyJumpUp,
                  keyJumpDown: _keyJumpDown,
                  keyJumpLeft: _keyJumpLeft,
                  keyJumpRight: _keyJumpRight,
                  isAutoJumpEnabled: _isAutoJumpEnabled,
                  activeStepKey: currentStepKey,
                  // Aqui passamos a configuração que move o joystick
                  isJoystickLeft: moveJoystickLeft,
                  onAutoJumpToggled: (value) {
                      if (!isAutoJumpActionStep) return;
                     setState(() => _isAutoJumpEnabled = value);
                     _handleAction(_keyAutoJumpToggle);
                  },
                  onPalitoVTapped: _onPalitoVTapped,
                  onPalitoDDTapped: _onPalitoDDTapped,
                  onPalitoDETapped: _onPalitoDETapped,
                  onPalitoHTapped: _onPalitoHTapped,
                  onJumpUp: () {
                    Provider.of<CharacterController>(context, listen: false).moveUp();
                    _handleAction(_keyJumpUp);
                  },
                  onJumpDown: () {
                    Provider.of<CharacterController>(context, listen: false).moveDown();
                    _handleAction(_keyJumpDown);
                  },
                  onJumpLeft: () {
                    Provider.of<CharacterController>(context, listen: false).moveLeft();
                    _handleAction(_keyJumpLeft);
                  },
                  onJumpRight: () {
                    Provider.of<CharacterController>(context, listen: false).moveRight();
                    _handleAction(_keyJumpRight);
                  },
                ),
              ),
            ],
          ),

          // VLibras sempre visível e fixo na direita (pois o joystick sairá da frente dele)
          const Positioned(
  bottom: 0,
  right: 0,
  child: ExcludeSemantics(child: VLibrasWidget()),
),
        ],
      ),
    );
  }
}