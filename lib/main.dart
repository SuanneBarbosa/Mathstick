import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/character_service.dart';
import 'services/palito_service.dart';
import 'services/tutorial_service.dart';
import 'user_interface/screens/splash_screen.dart'; 
import 'user_interface/screens/informative_tutorial_screen.dart';
import 'user_interface/screens/mathsticks_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterController()),
        ChangeNotifierProvider(create: (_) => PalitoController()), 
      ],
      child: MaterialApp(
        title: 'Mathsticks',
        home: kIsWeb ? const WebHome() : const SplashScreen(),
      ),
    );
  }
}

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  bool? _tutorialCompleted;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final completed = await TutorialService().isInformativeTutorialCompleted();
    if (mounted) {
      setState(() {
        _tutorialCompleted = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tutorialCompleted == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _tutorialCompleted!
        ? const Mathsticks()
        : const InformativeTutorialScreen();
  }
}