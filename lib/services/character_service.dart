import 'package:flutter/material.dart';

class CharacterController extends ChangeNotifier {
  double _xPosition = 0;
  double _yPosition = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  final double _characterSize = 100.0;
  double _stepSize = 69.0;
  bool isHistoryMode = false;

  final Set<String> _alertedEdges = {};

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

  void moveRight() {
    _xPosition += _stepSize;
    _xPosition = _xPosition.clamp(0, _screenWidth - _characterSize);
    notifyListeners();
  }

  void moveUp() {
    _yPosition -= _stepSize;
    _yPosition = _yPosition.clamp(0, _screenHeight - _characterSize);
    notifyListeners();
  }

  void moveDown() {
    final double newY = _yPosition + _stepSize;
    final double bottomLimit = _screenHeight - _characterSize;

    if (!isHistoryMode) {
      _yPosition = newY.clamp(0, bottomLimit);
      notifyListeners();
      return;
    }

    if (newY > bottomLimit) {
      if (!_alertedEdges.contains('bottom')) {
        _alertedEdges.add('bottom');
      }
      _yPosition = bottomLimit;
    } else {
      _alertedEdges.remove('bottom');
      _yPosition = newY;
    }

    notifyListeners();
  }

  void moveLeft() {
    final double newX = _xPosition - _stepSize;

    if (!isHistoryMode) {
      _xPosition = newX.clamp(0, _screenWidth - _characterSize);
      notifyListeners();
      return;
    }

    if (newX < 0) {
      if (!_alertedEdges.contains('left')) {
        _alertedEdges.add('left');
      }
      _xPosition = 0;
    } else {
      _alertedEdges.remove('left');
      _xPosition = newX;
    }

    notifyListeners();
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
