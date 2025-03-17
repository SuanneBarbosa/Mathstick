
enum StoryActionType {
  move,
  palito,
}

class StoryAction {
  final StoryActionType type;
  final String? direction; 
  final String? palitoType;
  // final double? size;
  final String Function(String) getActionLabel;

  // StoryAction({required this.type, this.direction, this.palitoType, this.size, required this.getActionLabel,});
 StoryAction({required this.type, this.direction, this.palitoType, required this.getActionLabel,});
  @override
  String toString() {
    if (type == StoryActionType.move) {
       return getActionLabel(direction ?? '');  
    } else {
       return getActionLabel(palitoType ?? '');
    }
  }
}