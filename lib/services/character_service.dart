
import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0;
  double _yPosition = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  
  double _stepSize = 70.0;
  bool isHistoryMode = false;

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  double get characterSize => _stepSize;

  void setScreenSize(double width, double height) {
    if (_screenWidth == width && _screenHeight == height) {
      return;
    }

    _screenWidth = width;
    _screenHeight = height;

    resetPosition();
  }

  void resetPosition() {
    if (_screenWidth > 0 && _screenHeight > 0) {
      _xPosition = (_screenWidth - _stepSize) / 2;
      _yPosition = (_screenHeight - _stepSize) / 2;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        snapToGrid();
      });
    }
  }

  void setStepSize(double newStepSize) {
    _stepSize = newStepSize;
    snapToGrid();
  }
  
  void snapToGrid() {
    if (_screenWidth <= 0 || _screenHeight <= 0 || _stepSize <= 0) {
      return;
    }

    final double centerX = _xPosition + (_stepSize / 2);
    final double centerY = _yPosition + (_stepSize / 2);

    final int col = (centerX / _stepSize).round();
    final int row = (centerY / _stepSize).round();

    _xPosition = (col * _stepSize) - (_stepSize / 2);
    
    _yPosition = row * _stepSize;

    final double rightLimit = _screenWidth - _stepSize;
    final double bottomLimit = _screenHeight - _stepSize;
  
    _xPosition = _xPosition.clamp(0, rightLimit);
    _yPosition = _yPosition.clamp(0, bottomLimit);

    if (hasListeners) {
      notifyListeners();
    }
  }
  
  double get xPosition => _xPosition;
  double get yPosition => _yPosition;

  bool moveRight() {
    final double nextX = _xPosition + _stepSize;
    final double rightLimit = _screenWidth - _stepSize;
    if (nextX <= rightLimit) {
      _xPosition = nextX;
      notifyListeners();
      return true;
    }
    return false; 
  }

  bool moveLeft() {
    final double nextX = _xPosition - _stepSize;
    if (nextX >= 0) {
      _xPosition = nextX;
      notifyListeners();
      return true; 
    }
    return false; 
  }

 bool moveUp() {
    final double nextY = _yPosition - _stepSize;
    if (nextY >= 0) {
      _yPosition = nextY;
      notifyListeners();
      return true; 
    }
    return false; 
  }

  bool moveDown() {
    final double nextY = _yPosition + _stepSize;
    final double bottomLimit = _screenHeight - _stepSize;
    if (nextY <= bottomLimit) {
      _yPosition = nextY;
      notifyListeners();
      return true; 
    }
    return false;
  }

  bool isAtAnyBorder() {
    return _xPosition < 5 ||
        _xPosition >= _screenWidth - _stepSize ||
        _yPosition < 5 ||
        _yPosition >= _screenHeight - _stepSize;
  }
  
  String getBorderHit() {
    if (_yPosition >= _screenHeight - _stepSize) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_xPosition <= 0) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_xPosition >= _screenWidth - _stepSize) {
      return "Você atingiu a borda! A história não pode continuar";
    } else if (_yPosition <= 0) {
      return "Você atingiu a borda! A história não pode continuar";
    }
    return "";
  }
}