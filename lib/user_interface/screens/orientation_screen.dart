import 'package:flutter/material.dart';
import '../../../services/tutorial_service.dart';
import 'informative_tutorial_screen.dart';

class OrientationScreen extends StatelessWidget {
  const OrientationScreen({super.key});

  Future<void> _onContinue(BuildContext context) async {
    final tutorialService = TutorialService();
    await tutorialService.markOrientationAsShown();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InformativeTutorialScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String titulo = 'Orientação do Dispositivo.';
    const String conteudo = 'Antes de utilizar o aplicativo, posicione o celular na sua mão, em modo paisagem, girando no sentido anti-horário.';
    const String instrucaoAcessibilidade = 'Clique no botão OK abaixo para fechar esta tela.';
    final String fullSemanticLabel = '$titulo $conteudo $instrucaoAcessibilidade';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(220, 247, 255, 1.0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Semantics(
            label: fullSemanticLabel,
            container: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ExcludeSemantics(
                  child: Text(
                    titulo,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const ExcludeSemantics(
                  child: Text(
                    conteudo,
                    style: TextStyle(fontSize: 18, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _onContinue(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}