import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0; // Posição inicial no eixo X
  double _yPosition = 0; // Posição inicial no eixo Y
  late double _screenWidth; // Largura da tela
  late double _screenHeight; // Altura da tela
  double _characterSize = 100.0; // Tamanho do personagem (altura)
  double _stepSize = 69.0;

  

  void setStepSize(double newStepSize) {
    _stepSize = newStepSize;
    notifyListeners(); // Notifica os listeners sobre a mudança
  }

  // Setando os tamanhos da tela
  void setScreenSize(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;

    // Calcula e define a posição central
    _xPosition = (width - _characterSize) / 2;
    _yPosition = (height - _characterSize) / 2;
    notifyListeners(); // Notifica os listeners sobre a mudança de posição
  }


  // Getter para posições
  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  // Movimento para a esquerda
   void moveLeft() {
    if (_xPosition >= _stepSize) {
      _xPosition -= _stepSize;
      notifyListeners();
    }
  }

  void moveRight() {
    if (_xPosition <= _screenWidth - _characterSize - _stepSize) {
      _xPosition += _stepSize;
      notifyListeners();
    }
  }

  void moveUp() {
    if (_yPosition >= _stepSize) {
      _yPosition -= _stepSize;
      notifyListeners();
    }
  }

  void moveDown() {
    if (_yPosition <= _screenHeight - _characterSize - _stepSize) {
      _yPosition += _stepSize;
      notifyListeners();
    }
  }
}