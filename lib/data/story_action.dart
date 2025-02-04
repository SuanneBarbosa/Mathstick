

enum StoryActionType {
  move,
  palito,
}

class StoryAction {
  final StoryActionType type;
  final String? direction; // Para movimentos
  final String? palitoType; // Para palitos
  final double? size;

  StoryAction({required this.type, this.direction, this.palitoType, this.size});

  @override
  String toString() {
    if (type == StoryActionType.move) {
      return 'Mover para $direction';
    } else {
      return 'Palito $palitoType';
    }
  }
}