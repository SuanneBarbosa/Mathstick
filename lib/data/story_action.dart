



enum StoryActionType {
  move,
  palito,
}

class StoryAction {
  final StoryActionType type;
  final String? direction; // Para movimentos
  final String? palitoType; // Para palitos
  final double? size;
  final String Function(String) getActionLabel;

  StoryAction({required this.type, this.direction, this.palitoType, this.size, required this.getActionLabel,});

  @override
  String toString() {
    if (type == StoryActionType.move) {
       return getActionLabel(direction ?? ''); // Chame usando 
    } else {
       return getActionLabel(palitoType ?? '');
    }
  }
}