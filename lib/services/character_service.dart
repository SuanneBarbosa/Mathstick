import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0.0; // Posição inicial no eixo X
  double _yPosition = 0.0; // Posição inicial no eixo Y
  late double _screenWidth; // Largura da tela
  late double _screenHeight; // Altura da tela
  double _characterSize = 100.0; // Tamanho do personagem (altura)

  // Setando os tamanhos da tela
  void setScreenSize(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  // Getter para posições
  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  // Movimento para a esquerda
  void moveLeft() {
    if (_xPosition > 0) {
      _xPosition -= 100; // Move 10 unidades para a esquerda
      notifyListeners();
    }
  }

  // Movimento para a direita
  void moveRight() {
    if (_xPosition < _screenWidth - _characterSize) {
      _xPosition += 100; // Move 10 unidades para a direita
      notifyListeners();
    }
  }

  // Movimento para cima
  void moveUp() {
    if (_yPosition > 0) {
      _yPosition -= 15; // Move 10 unidades para cima
      notifyListeners();
    }
  }

  // Movimento para baixo (correção adicionada)
  void moveDown() {
    if (_yPosition < _screenHeight - _characterSize) {
      _yPosition += 15; // Move 10 unidades para baixo
      notifyListeners();
    }
  }
}

