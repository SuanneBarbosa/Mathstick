import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mathsticks/user_interface/screens/mathsticks_screen.dart';
import 'package:mathsticks/user_interface/screens/orientation_screen.dart';
import 'package:mathsticks/user_interface/screens/practical_tutorial_screen.dart';
import '../../services/tutorial_service.dart';
import 'informative_tutorial_screen.dart'; 



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    final tutorialService = TutorialService();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (kIsWeb) {
      final informativeCompleted = await tutorialService.isInformativeTutorialCompleted();
      if (!mounted) return;
      if (!informativeCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InformativeTutorialScreen()),
        );
        return;
      }

      final practicalCompleted = await tutorialService.isPracticalTutorialCompleted();
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

    } else {
      final orientationShown = await tutorialService.isOrientationShown();
      if (!mounted) return;
      if (!orientationShown) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrientationScreen()),
        );
        return;
      }

      final informativeCompleted = await tutorialService.isInformativeTutorialCompleted();
      if (!mounted) return;
      if (!informativeCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InformativeTutorialScreen()),
        );
        return;
      }
      
      final practicalCompleted = await tutorialService.isPracticalTutorialCompleted();
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
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(220, 247, 255, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Carregando...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}