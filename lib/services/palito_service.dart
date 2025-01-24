import 'package:flutter/material.dart';

class Palito {
  final Offset position; // Posição do palito na tela
  final String type; // Tipo do palito (diagonal, horizontal, vertical)
  final String semanticsLabel;

  Palito({required this.position, required this.type, required this.semanticsLabel});
}

class PalitoController extends ChangeNotifier {
  final List<Palito> _palitos = []; // Lista de palitos

  List<Palito> get palitos => _palitos;

  void addPalito(Offset position, String type, String semanticsLabel) {
  const validTypes = ["palitov", "palitodd", "palitode", "palitoh"];
  if (!validTypes.contains(type)) {
    throw ArgumentError("Tipo de palito inválido: $type");
  }
  _palitos.add(Palito(position: position, type: type, semanticsLabel: semanticsLabel));
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


void updatePalito(Palito oldPalito, Offset newPosition) {
  final index = _palitos.indexOf(oldPalito);
  if (index != -1) {
    _palitos[index] = Palito(
      position: newPosition,
      type: oldPalito.type,
      semanticsLabel: oldPalito.semanticsLabel,
    );
    notifyListeners();
  }
}


}
