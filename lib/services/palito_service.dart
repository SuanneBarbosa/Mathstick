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
}


class PalitoController extends ChangeNotifier {
  final List<Palito> _palitos = []; // Lista de palitos

  List<Palito> get palitos => _palitos;

  void addPalito(Offset position, String type, String semanticsLabel, double size) {
    const validTypes = ["palitov", "palitodd", "palitode", "palitoh"];
    if (!validTypes.contains(type)) {
      throw ArgumentError("Tipo de palito inválido: $type");
    }
    _palitos.add(
        Palito(position: position, type: type, semanticsLabel: semanticsLabel, size: size,));
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
