import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/character_service.dart';
import '../../../services/palito_service.dart';
import '../../../services/tutorial_service.dart';
import '../screens/mathsticks_screen.dart';
import '../widgets/practical_tutorial_ui.dart';
import 'package:flutter/services.dart';

enum TutorialPhase { manual, autoJump }

class TutorialStep {
  final GlobalKey targetKey;
  final String instruction;
  final String? palitoType;
  final Function? movementAction;

  TutorialStep({
    required this.targetKey,
    required this.instruction,
    this.palitoType,
    this.movementAction,
  });
}

class PracticalTutorialScreen extends StatefulWidget {
  const PracticalTutorialScreen({super.key});

  @override
  State<PracticalTutorialScreen> createState() =>
      _PracticalTutorialScreenState();
}

class _PracticalTutorialScreenState extends State<PracticalTutorialScreen> {
  final TutorialService _tutorialService = TutorialService();
  bool _showInteractiveTutorial = false;
  int _currentStepIndex = 0;
  bool _isAutoJumpEnabled = false;
  TutorialPhase _currentPhase = TutorialPhase.manual;

  final GlobalKey _keyPalitoV = GlobalKey();
  final GlobalKey _keyPalitoH = GlobalKey();
  final GlobalKey _keyPalitoDD = GlobalKey();
  final GlobalKey _keyPalitoDE = GlobalKey();
  final GlobalKey _keyAutoJumpToggle = GlobalKey();
  final GlobalKey _keyJumpUp = GlobalKey();
  final GlobalKey _keyJumpDown = GlobalKey();
  final GlobalKey _keyJumpLeft = GlobalKey();
  final GlobalKey _keyJumpRight = GlobalKey();

  final FocusNode _instructionFocusNode = FocusNode();
  final FocusNode _introFocusNode = FocusNode();
  final FocusNode _phase2DialogFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  late final List<TutorialStep> _manualTutorialSteps;
  late final List<TutorialStep> _autoJumpTutorialSteps;
  late final CharacterController _characterController;
  late final PalitoController _palitoController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _characterController =
        Provider.of<CharacterController>(context, listen: false);
    _palitoController = Provider.of<PalitoController>(context, listen: false);
    _defineTutorialSteps();
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  void _defineTutorialSteps() {
    _manualTutorialSteps = [
      TutorialStep(
        targetKey: _keyPalitoH,
        instruction:
            'Fase 1: Controle Manual.\nVamos fazer um quadrado. Comece adicionando um Palito Horizontal.',
        palitoType: 'Palito H',
      ),
      TutorialStep(
        targetKey: _keyPalitoV,
        instruction: 'Perfeito. Adicione um Palito Vertical.',
        palitoType: 'Palito V',
      ),
      TutorialStep(
        targetKey: _keyJumpRight,
        instruction: 'Ótimo! Agora mova o personagem clicando no botão Saltar Para Direita.',
        movementAction: _characterController.moveRight,
      ),
      TutorialStep(
        targetKey: _keyPalitoV,
        instruction: 'Perfeito. Adicione um Palito Vertical.',
        palitoType: 'Palito V',
      ),
      TutorialStep(
        targetKey: _keyJumpUp,
        instruction: 'Excelente! Agora, mova o personagem no botao Saltar Para cima.',
        movementAction: _characterController.moveUp,
      ),
      TutorialStep(
        targetKey: _keyJumpLeft,
        instruction: 'Mova o personagem no botão Saltar Para Esquerda.',
        movementAction: _characterController.moveLeft,
      ),
      TutorialStep(
        targetKey: _keyPalitoH,
        instruction:
            'Para fechar o quadrado, adicione um Palito Horizontal.',
        palitoType: 'Palito H',
      ),
    ];

    _autoJumpTutorialSteps = [
      TutorialStep(
        targetKey: _keyAutoJumpToggle,
        instruction:
            'Fase 2: Salto Automático!\nPrimeiro, ative o interruptor de "Salto Automático".',
      ),
      TutorialStep(
        targetKey: _keyPalitoH,
        instruction:
            'Agora, adicione um Palito Horizontal. O personagem saltará sozinho!',
        palitoType: 'Palito H',
      ),
      TutorialStep(
        targetKey: _keyPalitoV,
        instruction:
            'Ele deu um salto para a direita! Agora adicione um Palito Vertical.',
        palitoType: 'Palito V',
      ),
      TutorialStep(
        targetKey: _keyJumpLeft,
        instruction: 'Mova o personagem no botão Saltar Para Esquerda.',
        movementAction: _characterController.moveLeft,
      ),
      TutorialStep(
        targetKey: _keyJumpDown,
        instruction: 'Excelente! Agora, mova o personagem no botão Saltar Para Baixo.',
        movementAction: _characterController.moveDown,
      ),
      TutorialStep(
        targetKey: _keyPalitoV,
        instruction:
            'Perfeito! Adicione outro Palito Vertical e ele também saltará para cima.',
        palitoType: 'Palito V',
      ),
      TutorialStep(
        targetKey: _keyPalitoH,
        instruction:
            'Para finalizar o exercício, adicione um Palito Horizontal.',
        palitoType: 'Palito H',
      ),
    ];
  }
  
  void _startInteractiveTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _palitoController.clearPalitos();
      _characterController.setStepSize(70.0);
      _characterController.setScreenSize(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height);
    });

    setState(() {
      _showInteractiveTutorial = true;
      _currentPhase = TutorialPhase.manual;
      _currentStepIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _showHighlight());
  }

  void _onAction(Function action) {
    action();
    final steps = _currentPhase == TutorialPhase.manual
        ? _manualTutorialSteps
        : _autoJumpTutorialSteps;
    final currentStep = steps[_currentStepIndex];
    if (currentStep.movementAction != null) {
      _nextStep();
    }
  }

  void _addPalito(String type, String label) {
    final position = _palitoController.getPositionForNewPalito(type,
        Offset(_characterController.xPosition, _characterController.yPosition),
        _characterController.characterSize);

    _palitoController.addPalito(
        position, type, label, _characterController.characterSize);

    final steps = _currentPhase == TutorialPhase.manual
        ? _manualTutorialSteps
        : _autoJumpTutorialSteps;
    final currentStep = steps[_currentStepIndex];

    if (currentStep.palitoType == type) {
      _nextStep();
    }

    if (_isAutoJumpEnabled && _currentPhase == TutorialPhase.autoJump) {
      switch (type) {
        case 'Palito V':
          _characterController.moveUp();
          break;
        case 'Palito H':
          _characterController.moveRight();
          break;
        case 'Palito DD':
          _characterController.moveRight();
          break;
      }
    }
  }

  void _nextStep() {
    if (!mounted) return;
    final steps = (_currentPhase == TutorialPhase.manual)
        ? _manualTutorialSteps
        : _autoJumpTutorialSteps;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_currentStepIndex < steps.length - 1) {
        setState(() => _currentStepIndex++);
        WidgetsBinding.instance.addPostFrameCallback((_) => _showHighlight());
      } else {
        if (_currentPhase == TutorialPhase.manual) {
          _showPhaseCompletionMessage(
            message: "Você completou a Fase 1 e fez um quadrado.",
            onAcknowledge: _startAutoJumpPhase,
          );
        } else {
          _showPhaseCompletionMessage(
            message: "Você concluiu a Fase 2 e fez um quadrado utilizando o Salto Automático. O tutorial está completo agora é com você!",
            onAcknowledge: () => _completeAndNavigate(context),
          );
        }
      }
    });
  }

  void _showPhaseCompletionMessage({required String message, required VoidCallback onAcknowledge}) {
    _removeHighlight();
    
    final String semanticLabel = "Fase Concluída! $message. Clique no botão continuar.";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: null, 
        content: Semantics(
          label: semanticLabel,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Fase Concluída!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            autofocus: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              onAcknowledge();
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }

  void _startAutoJumpPhase() {
    _removeHighlight();
    const String semanticLabel =
        "Fase 2: Salto Automático. Ótimo! Agora vamos aprender a usar o Salto Automático. Após ativá-lo, o personagem se moverá sozinho sempre que você adicionar um palito. Clique no botão começar.";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: null,
        content: Focus( 
          focusNode: _phase2DialogFocusNode,
          autofocus: true,
          child: Semantics(
            label: semanticLabel,
            child: const ExcludeSemantics(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Fase 2: Salto Automático",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                   SizedBox(height: 16),
                   Text(
                    "Ótimo! Agora vamos aprender a usar o Salto Automático. Após ativá-lo, o personagem se moverá sozinho sempre que você adicionar um palito.",
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentPhase = TutorialPhase.autoJump;
                _currentStepIndex = 0;
                _palitoController.clearPalitos();
                _characterController.resetPosition();
              });
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _showHighlight());
            },
            child: const Text("Começar"),
          )
        ],
      ),
    );
  }

  void _showHighlight() {
    _removeHighlight();

    final steps = (_currentPhase == TutorialPhase.manual)
        ? _manualTutorialSteps
        : _autoJumpTutorialSteps;
    if (_currentStepIndex >= steps.length) return;
    final step = steps[_currentStepIndex];

    if (step.targetKey.currentContext == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _showHighlight();
      });
      return;
    }

    final renderBox =
        step.targetKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final highlightRect = Rect.fromLTWH(
            offset.dx, offset.dy, renderBox.size.width, renderBox.size.height)
        .inflate(8.0);

    _overlayEntry = OverlayEntry(builder: (_) {
      final screenSize = MediaQuery.of(context).size;
      final topSafeArea = MediaQuery.of(context).padding.top;
      const double instructionTopPadding = 40.0;
      double instructionTopPosition = topSafeArea + instructionTopPadding;
      const double instructionBoxHeight = 100.0;
      final instructionRect = Rect.fromLTWH(
        0,
        instructionTopPosition,
        screenSize.width,
        instructionBoxHeight,
      );
      final bool doesOverlap = highlightRect.overlaps(instructionRect);
      double? finalTop;
      double? finalBottom;
      if (doesOverlap) {
        finalTop = null;
        finalBottom = screenSize.height / 2;
      } else {
        finalTop = instructionTopPosition;
        finalBottom = null;
      }

      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            IgnorePointer(
              child: ClipPath(
                clipper: InvertedClipper(
                    rect: highlightRect, radius: const Radius.circular(12)),
                child: Container(color: Colors.black.withOpacity(0.7)),
              ),
            ),
            Positioned.fromRect(
              rect: highlightRect,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellowAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              top: finalTop,
              bottom: finalBottom,
              left: screenSize.width * 0.2,
              right: screenSize.width * 0.2,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Focus(
                    focusNode: _instructionFocusNode,
                    child: Semantics(
                      liveRegion: true,
                      label: step.instruction,
                      child: ExcludeSemantics(
                        child: Text(
                          step.instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.9)),
                    onPressed: () => _completeAndNavigate(context),
                    child: const Text('Pular Tutorial'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _instructionFocusNode.canRequestFocus) {
          _instructionFocusNode.requestFocus();
        }
      });
    }
  }

  void _removeHighlight() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _completeAndNavigate(BuildContext context) async {
    _removeHighlight();
    await _tutorialService.completePracticalTutorial();
    if (mounted) {
      Provider.of<PalitoController>(context, listen: false).clearPalitos();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Mathsticks()),
      );
    }
  }

  @override
  void dispose() {
    _removeHighlight();
    _instructionFocusNode.dispose();
    _introFocusNode.dispose();
    _phase2DialogFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showInteractiveTutorial
        ? _buildInteractiveView()
        : _buildIntroView();
  }

  Widget _buildIntroView() {
    const String semanticLabel =
        'Tutorial Prático. Agora, vamos fazer dois exercícios rápidos para desenhar na tela. Clique no botão Começar para iniciar.';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(220, 247, 255, 1.0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Focus(
                focusNode: _introFocusNode,
                autofocus: true,
                child: Semantics(
                  label: semanticLabel,
                  child: const ExcludeSemantics(
                    child: Column(
                      children: [
                        Text(
                          'Tutorial Prático',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Agora, vamos fazer dois exercícios rápidos para desenhar na tela.',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _startInteractiveTutorial,
                    child: const Text('Começar'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: () => _completeAndNavigate(context),
                    child: const Text('Pular'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!kIsWeb)
                Semantics(
                  label: 'Sair do aplicativo',
                  button: true,
                  child: ExcludeSemantics(
                    child: TextButton.icon(
                      onPressed: _exitApp,
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      label: const Text('Sair do Aplicativo',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveView() {
    final steps = (_currentPhase == TutorialPhase.manual)
        ? _manualTutorialSteps
        : _autoJumpTutorialSteps;
    final GlobalKey currentStepKey = steps[_currentStepIndex].targetKey;
    final bool isAutoJumpStepActive = _currentPhase == TutorialPhase.autoJump &&
        steps.isNotEmpty &&
        steps[_currentStepIndex].targetKey == _keyAutoJumpToggle;

    return Scaffold(
        backgroundColor: const Color.fromRGBO(220, 247, 255, 1.0),
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
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Switch(
                key: _keyAutoJumpToggle,
                value: _isAutoJumpEnabled,
                activeColor: Colors.blue,
                onChanged: isAutoJumpStepActive
                    ? (value) {
                        setState(() => _isAutoJumpEnabled = value);
                        _nextStep();
                      }
                    : null,
              ),
            ],
          ),
        ),
        body: Column(children: [
          Expanded(
            child: PracticalTutorialUI(
              keyPalitoV: _keyPalitoV,
              keyPalitoH: _keyPalitoH,
              keyPalitoDD: _keyPalitoDD,
              keyPalitoDE: _keyPalitoDE,
              keyJumpUp: _keyJumpUp,
              keyJumpDown: _keyJumpDown,
              keyJumpLeft: _keyJumpLeft,
              keyJumpRight: _keyJumpRight,
              keyAutoJumpToggle: _keyAutoJumpToggle,
              isAutoJumpEnabled: _isAutoJumpEnabled,
              currentPhase: _currentPhase,
              activeStepKey: currentStepKey,
              onPalitoVTapped: () => _addPalito('Palito V', 'Palito Vertical'),
              onPalitoHTapped: () =>
                  _addPalito('Palito H', 'Palito Horizontal'),
              onPalitoDDTapped: () =>
                  _addPalito('Palito DD', 'Palito Diagonal a Direita'),
              onPalitoDETapped: () =>
                  _addPalito('Palito DE', 'Palito diagonal a Esquerda'),
              onJumpUp: () => _onAction(_characterController.moveUp),
              onJumpDown: () => _onAction(_characterController.moveDown),
              onJumpLeft: () => _onAction(_characterController.moveLeft),
              onJumpRight: () => _onAction(_characterController.moveRight),
              onAutoJumpToggled: (value) {
                setState(() => _isAutoJumpEnabled = value);
                final currentSteps = _currentPhase == TutorialPhase.autoJump
                    ? _autoJumpTutorialSteps
                    : [];
                if (currentSteps.isNotEmpty &&
                    currentSteps[_currentStepIndex].targetKey ==
                        _keyAutoJumpToggle) {
                  _nextStep();
                }
              },
            ),
          )
        ]));
  }
}

class InvertedClipper extends CustomClipper<Path> {
  final Rect rect;
  final Radius radius;

  InvertedClipper({required this.rect, required this.radius});

  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(RRect.fromRectAndRadius(rect, radius)),
    );
  }

  @override
  bool shouldReclip(covariant InvertedClipper oldClipper) =>
      oldClipper.rect != rect || oldClipper.radius != radius;
}