import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/tutorial_service.dart';
import 'enter_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  Timer? _timer;
  bool _orientationShown = false;
  bool _tutorialCompleted = false;

  @override
  void initState() {
    super.initState();

    // Trava a orientação para vertical no início
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Carrega o status do tutorial/orientação em segundo plano
    _loadStatus();

    // Trigger de animação de fade in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Auto navigate after 3 seconds
    _timer = Timer(const Duration(seconds: 3), _navigateToEnterScreen);
  }

  Future<void> _loadStatus() async {
    final tutorialService = TutorialService();
    final orientationShown = await tutorialService.isOrientationShown();
    final tutorialCompleted =
        await tutorialService.isInformativeTutorialCompleted();
    if (mounted) {
      setState(() {
        _orientationShown = orientationShown;
        _tutorialCompleted = tutorialCompleted;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToEnterScreen() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EnterScreen(
            orientationShown: _orientationShown,
            tutorialCompleted: _tutorialCompleted,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Stack(
        children: [
          // Centered main logo with fade-in effect
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: _opacity == 1.0 ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeOutBack,
                    child: Hero(
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
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Supporters logo in the bottom area (centered badge)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOut,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSupporterLogo('assets/images/CNPQ_Logo.png'),
                      const SizedBox(width: 16),
                      _buildSupporterLogo('assets/images/IFSP_Logo.png'),
                      const SizedBox(width: 16),
                      _buildSupporterLogo('assets/images/RUMO_Logo.png'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupporterLogo(String assetPath) {
    return Image.asset(
      assetPath,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }
}
