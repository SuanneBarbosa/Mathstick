import 'package:flutter/material.dart';

class Palito {
  final Offset position;
  final String type;
  final String semanticsLabel;
  final double size;

  Palito({
    required this.position,
    required this.type,
    required this.semanticsLabel,
    required this.size,
  });

 Offset getWrappedPosition(double screenWidth, double screenHeight) {
    double x = position.dx;
    double y = position.dy;

    if (x < -size) {
      x += screenWidth + size;
    } else if (x > screenWidth) {
      x -= screenWidth + size;
    }

    if (y < -size) {
      y += screenHeight + size;
    } else if (y > screenHeight) {
      y -= screenHeight + size;
    }

    return Offset(x, y);
  }
  
  bool isPartiallyOutside(double screenWidth, double screenHeight) {
    final double left   = position.dx;
    final double top    = position.dy;
    final double right  = left + size;
    final double bottom = top + size;

    final bool fullyInside = (left >= 0) &&
                             (right <= screenWidth) &&
                             (top >= 0) &&
                             (bottom <= screenHeight);

    final bool fullyOutside = (right < 0) ||
                              (left > screenWidth) ||
                              (bottom < 0) ||
                              (top > screenHeight);
    return !fullyInside && !fullyOutside;
  }
}

class PalitoController extends ChangeNotifier {
  final List<Palito> _palitos = []; // Lista de palitos

  List<Palito> get palitos => _palitos;

  void addPalito(Offset position, String type, String semanticsLabel, double size) {
    const validTypes = ["Palito V", "Palito DD", "Palito DE", "Palito H"];
    if (!validTypes.contains(type)) {
      throw ArgumentError("Tipo de palito inválido: $type");
    }
    _palitos.add(
      Palito(
        position: position,
        type: type,
        semanticsLabel: semanticsLabel,
        size: size,
      ),
    );
    notifyListeners();
  }

  void removePalito(Palito palito) {
    _palitos.remove(palito);
    notifyListeners();
  }

  void clearPalitos() {
    _palitos.clear();
    notifyListeners();
  }
}
