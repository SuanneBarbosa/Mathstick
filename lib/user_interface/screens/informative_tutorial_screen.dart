
import 'package:flutter/material.dart';
import 'package:mathsticks/user_interface/screens/mathsticks_screen.dart';
import 'package:provider/provider.dart';
import '../../../services/character_service.dart';
import '../../../services/tutorial_service.dart';
import '../screens/practical_tutorial_screen.dart';
import '../widgets/informative_tutorial_ui.dart';
import '../../../services/palito_service.dart';
import 'package:flutter/services.dart';


class InfoStep {
  final GlobalKey? targetKey;
  final String Function(BuildContext) getInstruction;
  final Widget? customHighlight;
  final bool isActionStep;

  InfoStep({
    this.targetKey,
    required this.getInstruction,
    this.customHighlight,
    this.isActionStep = false,
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

  // Chaves para identificar os widgets que queremos destacar
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
      Provider.of<PalitoController>(context, listen: false).clearPalitos();

      final ctrl = Provider.of<CharacterController>(context, listen: false);
      final size = MediaQuery.of(context).size;
      ctrl.setStepSize(70.0);
      ctrl.setScreenSize(size.width, size.height);

      _setupSteps();
      _showHighlight();
    });
  }


  void _setupSteps() {
    _tutorialSteps = [
      InfoStep(
        getInstruction: (_) =>
            'Bem-vindo ao Mathsticks! Sua tela é dividida em uma grade com linhas e colunas.',
      ),
      InfoStep(
        getInstruction: (_) =>
            'As colunas são organizadas em ordem alfabética da esquerda para a direita, e as linhas em ordem numérica de cima para baixo.',
      ),
      InfoStep(
        targetKey: _keyCharacter,
        getInstruction: (_) =>
            'No aplicativo, temos o personagem Beija-flor. Ele serve como o ponto de referência, para todos os palitos que você adicionar na tela.',
      ),
      InfoStep(
        targetKey: _keyPalitoButtons,
        getInstruction: (_) =>
            'Para escolher e adicionar um dos quatro tipos de palitos, use os botões no canto superior esquerdo da tela.',
      ),
      InfoStep(
        targetKey: _keyJoystick,
        getInstruction: (_) =>
            'E para mover o personagem pela grade, use os botões de salto no canto inferior direito da tela.',
      ),
      InfoStep(
        targetKey: _keyAutoJumpToggle,
        getInstruction: (_) =>
            'Na parte superior central da tela, você encontrará a opção “Salto Automático”. Ao ativá-la, sempre que um novo palito for adicionado, o personagem saltará automaticamente para a próxima posição.',
      ),
      InfoStep(
        targetKey: _keyPalitoV,
        isActionStep: true,
        getInstruction: (context) {
          final characterCtrl =
              Provider.of<CharacterController>(context, listen: false);
          final palitoCtrl =
              Provider.of<PalitoController>(context, listen: false);
          final cellSize = characterCtrl.characterSize;

          final palitoPosition = palitoCtrl.getPositionForNewPalito(
            'Palito V',
            Offset(characterCtrl.xPosition, characterCtrl.yPosition),
            cellSize,
          );
          final palitoCenter = Offset(
            palitoPosition.dx + cellSize / 2,
            palitoPosition.dy + cellSize / 2,
          );
          final screenWidth = MediaQuery.of(context).size.width;
          final numColumns = (screenWidth / cellSize).floor();
          final col =
              (palitoCenter.dx / cellSize).floor().clamp(0, numColumns - 1);
          final row = (palitoCenter.dy / cellSize).floor();
          final colLetter = String.fromCharCode('A'.codeUnitAt(0) + col);
          final rowNum = row + 1;

          return 'Vamos testar! Se você adicionar um palito agora, ele será colocado na Coluna $colLetter, Linha $rowNum. Então clique no botão do Palito "V" que significa Palito Vertical para continuar.';
        },
      ),
      InfoStep(
        targetKey: _keyPalitoDD,
        getInstruction: (_) =>
            'Ótimo! Agora clique no botão do Palito "DD" que significa Palito Diagonal à Direita.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyPalitoDE,
        getInstruction: (_) =>
            'Perfeito. Clique no botão do Palito "DE" que significa Palito Diagonal à Esquerda.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyPalitoH,
        getInstruction: (_) =>
            'Excelente! Agora, clique no botão do Palito "H" que significa Palito Horizontal.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyJumpUp,
        getInstruction: (_) =>
            'Agora teste os saltos. Toque no botão de Saltar para CIMA.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyJumpDown,
        getInstruction: (_) => 'Isso! Agora toque no botão de Saltar para BAIXO.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyJumpLeft,
        getInstruction: (_) => 'Quase lá. Toque no botão de Saltar para a ESQUERDA.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyJumpRight,
        getInstruction: (_) => 'E por fim, toque no botão de Saltar para a DIREITA.',
        isActionStep: true,
      ),
      InfoStep(
        targetKey: _keyAutoJumpToggle,
        getInstruction: (_) =>
            'Para terminar, clique no botão de "Salto Automático" para ativá-lo.',
        isActionStep: true,
      ),
      InfoStep(
        getInstruction: (_) => 'Tudo pronto! Vamos para um exercício prático.',
      ),
    ];
  }

  void _nextStep() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_currentStepIndex < _tutorialSteps.length - 1) {
        setState(() => _currentStepIndex++);
        _showHighlight();
      } else {
        _finishTutorial();
      }
    });
  }

  void _showHighlight() {
    _removeHighlight();
    if (_currentStepIndex >= _tutorialSteps.length) return;

    final step = _tutorialSteps[_currentStepIndex];

    _overlayEntry = OverlayEntry(
      builder: (context) {
        Rect highlightRect = Rect.zero;
        if (step.targetKey?.currentContext != null) {
          final renderBox =
              step.targetKey!.currentContext!.findRenderObject() as RenderBox;
          final offset = renderBox.localToGlobal(Offset.zero);
          highlightRect = Rect.fromLTWH(offset.dx, offset.dy,
                  renderBox.size.width, renderBox.size.height)
              .inflate(8.0);
        }

        final screenSize = MediaQuery.of(context).size;
        final topSafeArea = MediaQuery.of(context).padding.top;
        const double instructionTopPadding = 40.0;
        double instructionTopPosition = topSafeArea + instructionTopPadding;
        const double instructionBoxHeight = 100.0;
        final instructionRect = Rect.fromLTWH(
            0, instructionTopPosition, screenSize.width, instructionBoxHeight);
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
        if (step.targetKey == null) {
          finalTop = topSafeArea + instructionTopPadding;
          finalBottom = null;
        }

        final String baseInstruction = step.getInstruction(context);
        String semanticLabel = baseInstruction; 

        final bool isLastStep = _currentStepIndex == _tutorialSteps.length - 1;

        if (isLastStep) {
          semanticLabel = '$baseInstruction. Clique no botão concluir.';
        } else if (!step.isActionStep) {
          semanticLabel = '$baseInstruction. Clique no botão avançar para continuar.';
        }
        
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              IgnorePointer(
                child: ClipPath(
                  clipper: InvertedClipper(
                    rect: step.targetKey != null ? highlightRect : Rect.zero,
                    radius: const Radius.circular(12),
                  ),
                  child: Container(color: Colors.black.withOpacity(0.7)),
                ),
              ),
              if (step.targetKey != null)
                Positioned.fromRect(
                  rect: highlightRect,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.yellowAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (step.customHighlight != null)
                IgnorePointer(ignoring: true, child: step.customHighlight!),
              Positioned(
                top: finalTop,
                bottom: finalBottom,
                left: screenSize.width * 0.2,
                right: screenSize.width * 0.2,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        label: semanticLabel,
                        child: ExcludeSemantics(
                          child: Text(
                            baseInstruction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
                    
                    if (!step.isActionStep)
                      ElevatedButton(
                        onPressed: isLastStep ? _finishTutorial : _nextStep,
                        child: Text(isLastStep ? 'Concluir' : 'Avançar'),
                      ),
                    
                    
                    if (!step.isActionStep && !isLastStep)
                      const SizedBox(width: 16),
                    
                   
                    if (!isLastStep)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.cyanAccent.withOpacity(0.9)),
                        onPressed: _finishTutorial,
                        child: const Text('Pular Tutorial'),
                      ),
                  ],
                ),
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
    if (!mounted) return;

    final practicalCompleted =
        await _tutorialService.isPracticalTutorialCompleted();
    if (!mounted) return;

    if (!practicalCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PracticalTutorialScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Mathsticks()),
      );
    }
  }

  void _handleAction(GlobalKey key) {
    if (!mounted || _currentStepIndex >= _tutorialSteps.length) return;
    final step = _tutorialSteps[_currentStepIndex];
    if (step.isActionStep && step.targetKey == key) {
      _nextStep();
    }
  }

  void _onPalitoVTapped() {
    final characterCtrl =
        Provider.of<CharacterController>(context, listen: false);
    final palitoCtrl = Provider.of<PalitoController>(context, listen: false);
    final pos = palitoCtrl.getPositionForNewPalito('Palito V',
        Offset(characterCtrl.xPosition, characterCtrl.yPosition), 70.0);
    palitoCtrl.addPalito(pos, 'Palito V', 'Palito Vertical', 70.0);
    _handleAction(_keyPalitoV);
  }

  void _onPalitoDDTapped() {
    final characterCtrl =
        Provider.of<CharacterController>(context, listen: false);
    final palitoCtrl = Provider.of<PalitoController>(context, listen: false);
    final pos = palitoCtrl.getPositionForNewPalito('Palito DD',
        Offset(characterCtrl.xPosition, characterCtrl.yPosition), 70.0);
    palitoCtrl.addPalito(pos, 'Palito DD', 'Palito Diagonal à Direita', 70.0);
    _handleAction(_keyPalitoDD);
  }

  void _onPalitoDETapped() {
    final characterCtrl =
        Provider.of<CharacterController>(context, listen: false);
    final palitoCtrl = Provider.of<PalitoController>(context, listen: false);
    final pos = palitoCtrl.getPositionForNewPalito('Palito DE',
        Offset(characterCtrl.xPosition, characterCtrl.yPosition), 70.0);
    palitoCtrl.addPalito(
        pos, 'Palito DE', 'Palito Diagonal à Esquerda', 70.0);
    _handleAction(_keyPalitoDE);
  }

  void _onPalitoHTapped() {
    final characterCtrl =
        Provider.of<CharacterController>(context, listen: false);
    final palitoCtrl = Provider.of<PalitoController>(context, listen: false);
    final pos = palitoCtrl.getPositionForNewPalito('Palito H',
        Offset(characterCtrl.xPosition, characterCtrl.yPosition), 70.0);
    palitoCtrl.addPalito(pos, 'Palito H', 'Palito Horizontal', 70.0);
    _handleAction(_keyPalitoH);
  }

  @override
  void dispose() {
    _removeHighlight();
    _instructionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey? currentStepKey =
        _tutorialSteps.isNotEmpty ? _tutorialSteps[_currentStepIndex].targetKey : null;
    final bool isAutoJumpActionStep = _tutorialSteps.isNotEmpty &&
        _tutorialSteps[_currentStepIndex].isActionStep &&
        _tutorialSteps[_currentStepIndex].targetKey == _keyAutoJumpToggle;

    return Scaffold(
      backgroundColor: const Color(0xFFDCF7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
              onChanged: isAutoJumpActionStep
                  ? (value) {
                      setState(() => _isAutoJumpEnabled = value);
                      _handleAction(_keyAutoJumpToggle);
                    }
                  : null,
            ),
          ],
        ),
      ),
      body: Column(
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
              onAutoJumpToggled: (value) {
                setState(() => _isAutoJumpEnabled = value);
                _handleAction(_keyAutoJumpToggle);
              },
              onPalitoVTapped: _onPalitoVTapped,
              onPalitoDDTapped: _onPalitoDDTapped,
              onPalitoDETapped: _onPalitoDETapped,
              onPalitoHTapped: _onPalitoHTapped,
              onJumpUp: () {
                Provider.of<CharacterController>(context, listen: false)
                    .moveUp();
                _handleAction(_keyJumpUp);
              },
              onJumpDown: () {
                Provider.of<CharacterController>(context, listen: false)
                    .moveDown();
                _handleAction(_keyJumpDown);
              },
              onJumpLeft: () {
                Provider.of<CharacterController>(context, listen: false)
                    .moveLeft();
                _handleAction(_keyJumpLeft);
              },
              onJumpRight: () {
                Provider.of<CharacterController>(context, listen: false)
                    .moveRight();
                _handleAction(_keyJumpRight);
              },
            ),
          )
        ],
      ),
    );
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