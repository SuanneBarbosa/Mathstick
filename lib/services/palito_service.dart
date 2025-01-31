import 'package:flutter/material.dart';

class Palito {
  final Offset position; // Posição do palito na tela
  final String type; // Tipo do palito (diagonal, horizontal, vertical)
  final String semanticsLabel;
  final double size;

  Palito(
      {required this.position,
      required this.type,
      required this.semanticsLabel,
      required this.size,});
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
