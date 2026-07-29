import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mathsticks/user_interface/screens/mathsticks_screen.dart';
import 'package:mathsticks/user_interface/screens/orientation_screen.dart';
import 'informative_tutorial_screen.dart';

class EnterScreen extends StatelessWidget {
  final bool orientationShown;
  final bool tutorialCompleted;

  const EnterScreen({
    super.key,
    required this.orientationShown,
    required this.tutorialCompleted,
  });

  void _onEnter(BuildContext context) async {
    // Altera a orientação para horizontal antes de navegar para o resto do app
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (!context.mounted) return;

    if (!orientationShown) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const OrientationScreen(),
        ),
      );
    } else if (!tutorialCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const InformativeTutorialScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const Mathsticks(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // Smooth Hero transition from splash screen
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo/mathsticks.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note_rounded,
                          size: 200,
                          color: Color(0xFF4F46E5),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Accessible Enter Button
                  Semantics(
                    label:
                        'Botão Entrar. Dê dois toques para entrar no aplicativo.',
                    button: true,
                    enabled: true,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF312E81),
                        shadowColor:
                            const Color(0xFF4F46E5).withValues(alpha: 0.4),
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _onEnter(context),
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
