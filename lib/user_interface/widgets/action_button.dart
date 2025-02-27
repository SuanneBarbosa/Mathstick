import 'package:flutter/material.dart';
import '../../data/story_action.dart'; // <-- Arquivo renomeado

class ActionButton extends StatelessWidget {
  final StoryActionType type;
  final String value;
  final Function(StoryAction) onActionAdded; // Ajustar para StoryAction
  final double? palitoSize;
  final String Function(String) getActionLabel;

  const ActionButton({
    super.key,
    required this.type,
    required this.value,
    required this.onActionAdded,
    required this.getActionLabel,
    this.palitoSize,
    
  });

  @override
  Widget build(BuildContext context) {
    // Se for um movimento, mostra label como "Cima", "Baixo" etc
    // Se for palito, fazemos "Palito X"
    String label = type == StoryActionType.move ? value : 'Palito $value';
    // Ex: "palitov" => substring(6) = "v" => "V"

    return ElevatedButton(
      onPressed: () {
        // Agora instanciamos a classe StoryAction (não Action)
        final newAction = StoryAction(
          type: type,
          direction: type == StoryActionType.move ? value : null,
          palitoType: type == StoryActionType.palito ? value : null,
          size: palitoSize,
          getActionLabel: getActionLabel,
        );
        onActionAdded(newAction); 
      },
      child: Text(label),
    );
  }
}
