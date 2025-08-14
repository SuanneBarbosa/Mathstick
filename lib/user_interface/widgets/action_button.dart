import 'package:flutter/material.dart';
import '../../data/story_action.dart'; 

class ActionButton extends StatelessWidget {
  final StoryActionType type;
  final String value;
  final Function(StoryAction) onActionAdded; 
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
   
    String label = type == StoryActionType.move ? value : 'Palito $value';
   
    return ElevatedButton(
      onPressed: () {
        final newAction = StoryAction(
          type: type,
          direction: type == StoryActionType.move ? value : null,
          palitoType: type == StoryActionType.palito ? value : null,
          getActionLabel: getActionLabel,
        );
        onActionAdded(newAction); 
      },
      child: Text(label),
    );
  }
}
