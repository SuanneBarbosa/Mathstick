import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0; 
  double _yPosition = 0; 
  double _screenWidth = 0; 
  double _screenHeight = 0; 
  final double _characterSize = 100.0; 
  double _stepSize = 69.0;

  
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  void setStepSize(double newStepSize) {
    _stepSize = newStepSize;
    notifyListeners(); 
  }

 
  void setScreenSize(double width, double height) {
    if (_screenWidth == width && _screenHeight == height) {
      return; 
    }

    _screenWidth = width;
    _screenHeight = height;

   
    _xPosition = (width - _characterSize) / 2;
    _yPosition = (height - _characterSize) / 2;

      Future.microtask(() {
        notifyListeners();
      });
  }


  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

 
 void moveLeft() {
  if (_screenWidth == 1) return;
  _xPosition -= _stepSize;

 
  if (_xPosition < 0) {
    _xPosition = _screenWidth - _characterSize;
  }

  notifyListeners();
}

void moveRight() {
  if (_screenWidth == 1) return;
  _xPosition += _stepSize;

  
  if (_xPosition > _screenWidth - _characterSize) {
    _xPosition = 0;
  }

  notifyListeners();
}

void moveUp() {
  if (_screenWidth == 1) return;
  _yPosition -= _stepSize;

  
  if (_yPosition < 0) {       
    _yPosition = _screenHeight - _characterSize;
  }

  notifyListeners();
}

void moveDown() {
  if (_screenWidth == 1) return;
  _yPosition += _stepSize;

 
  if (_yPosition > _screenHeight - _characterSize) {
    _yPosition = 0;
  }

  notifyListeners();
}

}
