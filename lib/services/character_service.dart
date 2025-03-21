import 'package:flutter/material.dart';


// deu uma exceção quando testei :
// just_audio_web.dart  C:\Users\suan...\just_audio_web-0.4.14\lib

// • "implementation": Unknown word.  cSpell [Ln 51, Col 13]
// • "durationchange": Unknown word.  cSpell [Ln 116, Col 10]
// • "timeupdate": Unknown word.      cSpell [Ln 132, Col 10]
// ◉ "loadstart": Unknown word.       cSpell [Ln 138, Col 10]
// • "canplaythrough": Unknown word.  cSpell [Ln 153, Col 10]

// Excessão:
// ChromeProxyService: Failed to evaluate expression '': InvalidInputError: .
// RethrownDartError: AbortError: The play() request was interrupted by a new load request. https://goo.gl/LdLk22
// 2

// dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 329:10  createErrorWithStack
// errors.dart:329
// dart-sdk/lib/_internal/js_dev_runtime/patch/core_patch.dart 265:28            _throw
// core_patch.dart:265
// dart-sdk/lib/core/errors.dart 120:5                                           throwWithStackTrace
// errors.dart:120
// dart-sdk/lib/async/zone.dart 1386:11                                          callback
// zone.dart:1386
// dart-sdk/lib/async/schedule_microtask.dart 40:11                              _microtaskLoop
// schedule_microtask.dart:40
// dart-sdk/lib/async/schedule_microtask.dart 49:5                               _startMicrotaskLoop
// schedule_microtask.dart:49
// dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart 181:7      


// void moveCharacterWithStop(String direction) {
//     final characterController = Provider.of<CharacterController>(context, listen: false);
//     characterController.move(direction, stopStory); // Passa _stopStory como parâmetro
// }

class CharacterController extends ChangeNotifier {

  double _xPosition = 0; 
  double _yPosition = 0; 
  double _screenWidth = 0; 
  double _screenHeight = 0; 
  final double _characterSize = 100.0; 
  double _stepSize = 69.0;
  bool isHistoryMode = false; 


  final Set<String> _alertedEdges = {};
 
  String? _borderAlert;
  String? get borderAlert => _borderAlert;

  void _triggerBorderAlert(String msg) {
    _borderAlert = msg;
    notifyListeners();
  }

  // void clearBorderAlert() {
  //   _borderAlert = null;
  //   notifyListeners(); 
  // }

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


 
  // bool _canMoveUp() {
  //   return (_yPosition - _stepSize) >= 0;
  // }

  // bool _canMoveDown() {
  //   return (_yPosition + _stepSize + _characterSize) <= _screenHeight;
  // }

  // bool _canMoveLeft() {
  //   return (_xPosition - _stepSize) >= 0;
  // }

  // bool _canMoveRight() {
  //   return (_xPosition + _stepSize + _characterSize) <= _screenWidth;
  // }


// void moveLeft() {
//     _xPosition -= _stepSize;
//     _xPosition = _xPosition.clamp(0, _screenWidth - _characterSize); 
//     notifyListeners();
//   }

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

// void moveDown() {
  
//     _yPosition += _stepSize;
//     _yPosition = _yPosition.clamp(100, _screenHeight - _characterSize); 
//     notifyListeners();
//   }
  
// void moveUp() {
//     final double newY = _yPosition - _stepSize;
//     final double topLimit = 0;

//     if (newY < topLimit) {
//       if (!_alertedEdges.contains('top')) {
//         _alertedEdges.add('top');
//         _triggerBorderAlert("Você atingiu a borda SUPERIOR!");
//       }
//       _yPosition = topLimit;
//     } else {
//       _alertedEdges.remove('top');
//       _yPosition = newY;
//     }
//     notifyListeners();
//   }

//   void moveDown() {
//     final double newY = _yPosition + _stepSize;
//     final double bottomLimit = _screenHeight - _characterSize;

//     if (newY > bottomLimit) {
//       if (!_alertedEdges.contains('bottom')) {
//         _alertedEdges.add('bottom');
//         _triggerBorderAlert("Você atingiu a borda INFERIOR!");
//       }
//       _yPosition = bottomLimit;
//     } else {
//       _alertedEdges.remove('bottom');
//       _yPosition = newY;
//     }
//     notifyListeners();
//   }

//   void moveLeft() {
//     final double newX = _xPosition - _stepSize;

//     if (newX < 0) {
//       if (!_alertedEdges.contains('left')) {
//         _alertedEdges.add('left');
//         _triggerBorderAlert("Você atingiu a borda ESQUERDA!");
//       }
//       _xPosition = 0;
//     } else {
//       _alertedEdges.remove('left');
//       _xPosition = newX;
//     }
//     notifyListeners();
//   }

//   void moveRight() {
//     final double newX = _xPosition + _stepSize;
//     final double rightLimit = _screenWidth - _characterSize;

//     if (newX > rightLimit) {
//       if (!_alertedEdges.contains('right')) {
//         _alertedEdges.add('right');
//         _triggerBorderAlert("Você atingiu a borda DIREITA!");
//       }
//       _xPosition = rightLimit;
//     } else {
//       _alertedEdges.remove('right');
//       _xPosition = newX;
//     }
//     notifyListeners();
//   }

// void moveUp() {
//     final double newY = _yPosition - _stepSize;

//     if (!isHistoryMode) {
//       // Movimentação normal, sem alerta de borda
//       _yPosition = newY.clamp(0, _screenHeight - _characterSize);
//       notifyListeners();
//       return;
//     }

//     // Modo história: detectamos borda
//     if (newY < 0) {
//       // Bateu na borda superior
//       if (!_alertedEdges.contains('top')) {
//         _alertedEdges.add('top');
//           _triggerBorderAlert("Você atingiu a borda SUPERIOR!");
//       }
//       _yPosition = 0; // Encosta no topo
//     } else {
//       // Se moveu pra dentro, removemos a borda do set para futuro
//       _alertedEdges.remove('top');
//       _yPosition = newY;
//     }

//     notifyListeners();
//   }

  void moveDown() {
    final double newY = _yPosition + _stepSize;
    final double bottomLimit = _screenHeight - _characterSize;

    if (!isHistoryMode) {
      _yPosition = newY.clamp(0, bottomLimit);
      notifyListeners();
      return;
    }

    // Modo história
    if (newY > bottomLimit) {
      if (!_alertedEdges.contains('bottom')) {
        _alertedEdges.add('bottom');
        // stopStory();
          _triggerBorderAlert("Você atingiu a borda INFERIOR!");
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

    // Modo história
    if (newX < 0) {
      if (!_alertedEdges.contains('left')) {
        _alertedEdges.add('left');
          _triggerBorderAlert("Você atingiu a borda ESQUERDA!");
      }
      _xPosition = 0;
    } else {
      _alertedEdges.remove('left');
      _xPosition = newX;
    }

    notifyListeners();
  }

  // void moveRight() {
  //   final double newX = _xPosition + _stepSize;
  //   final double rightLimit = _screenWidth - _characterSize;

  //   if (!isHistoryMode) {
  //     _xPosition = newX.clamp(0, rightLimit);
  //     notifyListeners();
  //     return;
  //   }

  //   // Modo história
  //   if (newX > rightLimit) {
  //     if (!_alertedEdges.contains('right')) {
  //       _alertedEdges.add('right');
  //         _triggerBorderAlert("Você atingiu a borda DIREITA!");
  //     }
  //     _xPosition = rightLimit;
  //   } else {
  //     _alertedEdges.remove('right');
  //     _xPosition = newX;
  //   }

  //   notifyListeners();
  // }
}
