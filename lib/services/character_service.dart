import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0;
  double _yPosition = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  final double _characterSize = 100.0;
  double _stepSize = 69.0;
  bool isHistoryMode = false;

  //final Set<String> _alertedEdges = {};

  final double _characterOffsetX = 68.0; // Metade da altura da imagem (70/2)
  final double _characterOffsetY = 92.0; // Metade da altura da imagem (70/2)

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;


  // DENTRO DE CharacterController

// NOVA FUNÇÃO para alinhar a posição à grade atual
void snapToGrid() {
  if (_stepSize <= 0) return; // Evita divisão por zero

  // Calcula a coluna e a linha da grade mais próxima da posição atual
  final int col = (_xPosition / _stepSize).round();
  final int row = (_yPosition / _stepSize).round();

  // Define a nova posição como a intersecção dessa coluna/linha
  _xPosition = col * _stepSize;
  _yPosition = row * _stepSize;

  // Garante que a nova posição alinhada ainda esteja dentro dos limites da tela
  final double rightLimit = _screenWidth - _characterSize;
  final double bottomLimit = _screenHeight - _characterSize;
  
  _xPosition = _xPosition.clamp(0, rightLimit);
  _yPosition = _yPosition.clamp(0, bottomLimit);
}

void resetPosition() {
  // Recalcula a posição central com base nas dimensões da tela já armazenadas
  if (_screenWidth > 0 && _screenHeight > 0) {
    _xPosition = (_screenWidth - _characterSize) / 2;
    _yPosition = (_screenHeight - _characterSize) / 2;
    snapToGrid(); 
  }
}

  void setStepSize(double newStepSize) {
    _stepSize = newStepSize;
    snapToGrid();
    notifyListeners();
  }

  void setScreenSize(double width, double height) {
    if (_screenWidth == width && _screenHeight == height) {
      return;
    }

    _screenWidth = width;
    _screenHeight = height;

    // _xPosition = (width - _characterSize) / 2;
    // _yPosition = (height - _characterSize) / 2;

    final int centralCol = (width / _stepSize / 2).floor();
    final int centralRow = (height / _stepSize / 2).floor();

     _xPosition = (centralCol * _stepSize) - _characterOffsetX;
    _yPosition = (centralRow * _stepSize) - _characterOffsetY;

  
    _xPosition = _xPosition.clamp(0, _screenWidth - _characterSize);
    _yPosition = _yPosition.clamp(0, _screenHeight - _characterSize);

    Future.microtask(() {
      notifyListeners();
    });
  }

  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  void moveRight() {
  // Calcula a posição final do próximo passo
  final double nextX = _xPosition + _stepSize;
  
  // Define o limite máximo da borda direita
  final double rightLimit = _screenWidth - _characterSize;

  // VERIFICA ANTES DE MOVER: Só se move se o próximo passo COMPLETO couber.
  if (nextX <= rightLimit) {
    _xPosition = nextX;
    notifyListeners();
  }
  // Se não couber, não fazemos nada. O personagem fica parado.
}

void moveLeft() {
  // Calcula a posição final do próximo passo
  final double nextX = _xPosition - _stepSize;

  // VERIFICA ANTES DE MOVER: O limite esquerdo é 0.
  if (nextX >= 0) {
    _xPosition = nextX;
    notifyListeners();
  }
}

void moveUp() {
  // Calcula a posição final do próximo passo
  final double nextY = _yPosition - _stepSize;

  // VERIFICA ANTES DE MOVER: O limite superior é 0.
  if (nextY >= 0) {
    _yPosition = nextY;
    notifyListeners();
  }
}

void moveDown() {
  // Calcula a posição final do próximo passo
  final double nextY = _yPosition + _stepSize;

  // Define o limite máximo da borda inferior
  final double bottomLimit = _screenHeight - _characterSize;

  // VERIFICA ANTES DE MOVER: Só se move se o próximo passo COMPLETO couber.
  if (nextY <= bottomLimit) {
    _yPosition = nextY;
    notifyListeners();
  }
}

  

  bool isAtAnyBorder() {
    return _xPosition <= 0 ||
        _xPosition >= _screenWidth - _characterSize ||
        _yPosition <= 0 ||
        _yPosition >= _screenHeight - _characterSize;
  }


  String getBorderHit() {
    if (_yPosition >= _screenHeight - _characterSize) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_xPosition <= 0) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_xPosition >= _screenWidth - _characterSize) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_yPosition <= 0) {
      return "Você atingiu a borda! A história não pode continuar";
    }
    return "";
  }
}
