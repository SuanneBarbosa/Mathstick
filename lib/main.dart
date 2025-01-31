import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/character_service.dart';
import 'services/palito_service.dart';
import 'user_interface/screens/mathsticks_screen.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();

// Somente na orientação vertical.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);


  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterController()),
        ChangeNotifierProvider(create: (_) => PalitoController()), // Adiciona o PalitoController
      ],
      child: MaterialApp(
        title: 'Mathsticks',
        home: Mathsticks(),
      ),
    );
  }
}
