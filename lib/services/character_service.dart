import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0; // Posição inicial no eixo X
  double _yPosition = 0; // Posição inicial no eixo Y
  double _screenWidth = 1; // Largura da tela
  double _screenHeight = 1; // Altura da tela
  final double _characterSize = 100.0; // Tamanho do personagem (altura)
  double _stepSize = 69.0;

  // Getters para acessar os tamanhos da tela
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  void setStepSize(double newStepSize) {
    _stepSize = newStepSize;
    notifyListeners(); // Notifica os listeners sobre a mudança
  }

  // Setando os tamanhos da tela
  void setScreenSize(double width, double height) {
    if (_screenWidth == width && _screenHeight == height) {
      return; // Evita chamadas repetidas
    }

    _screenWidth = width;
    _screenHeight = height;

    // Calcula a posição inicial do personagem no centro da tela
    _xPosition = (width - _characterSize) / 2;
    _yPosition = (height - _characterSize) / 2;

      Future.microtask(() {
        notifyListeners();
      });
  }

  // Getter para posições
  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  // Movimento para a esquerda
 void moveLeft() {
  if (_screenWidth == 1) return;
  _xPosition -= _stepSize;

  // Se ultrapassar a borda esquerda, reaparece na direita
  if (_xPosition < 0) {
    _xPosition = _screenWidth - _characterSize;
  }

  notifyListeners();
}

void moveRight() {
  if (_screenWidth == 1) return;
  _xPosition += _stepSize;

  // Se ultrapassar a borda direita, reaparece na esquerda
  if (_xPosition > _screenWidth - _characterSize) {
    _xPosition = 0;
  }

  notifyListeners();
}

void moveUp() {
  if (_screenWidth == 1) return;
  _yPosition -= _stepSize;

  // Se ultrapassar a borda superior, reaparece na parte inferior
  if (_yPosition < 0) {
    _yPosition = _screenHeight - _characterSize;
  }

  notifyListeners();
}

void moveDown() {
  if (_screenWidth == 1) return;
  _yPosition += _stepSize;

  // Se ultrapassar a borda inferior, reaparece na parte superior
  if (_yPosition > _screenHeight - _characterSize) {
    _yPosition = 0;
  }

  notifyListeners();
}

}
