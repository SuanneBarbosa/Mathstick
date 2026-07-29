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

  bool isPartiallyOffscreen(
      double screenWidth, double screenHeight, BuildContext context) {
    final double left = position.dx;
    final double top = position.dy + MediaQuery.of(context).viewPadding.top;
    final double right = left + size;
    final double bottom = top + size;

    return left < 0 || top < 0 || right > screenWidth || bottom > screenHeight;
  }

  List<String> getOffscreenEdges(
      double screenWidth, double screenHeight, BuildContext context) {
    final edges = <String>[];

    final double leftPos = position.dx;
    final double topPos = position.dy + MediaQuery.of(context).viewPadding.top;
    final double rightPos = leftPos + size;
    final double bottomPos = topPos + size;

    if (leftPos < 0) {
      edges.add('left');
    }
    if (rightPos > screenWidth) {
      edges.add('right');
    }
    if (topPos < 0) {
      edges.add('top');
    }
    if (bottomPos > screenHeight) {
      edges.add('bottom');
    }

    return edges;
  }
}

class PalitoController extends ChangeNotifier {
  final List<Palito> _palitos = [];

  final Map<Palito, Set<String>> _edgesAlertedForPalito = {};

  List<Palito> get palitos => _palitos;
  
  Offset getPositionForNewPalito(String palitoType, Offset characterPosition, double palitoSize) {
    const double baseSize = 50.0;
    final sizeDiff = palitoSize - baseSize;
    double baseOffsetX = 0, baseOffsetY = 0;
    double finalOffsetX = 0, finalOffsetY = 0;

    switch (palitoType) {
      case "palito_v":
        baseOffsetX = 24;
        baseOffsetY = -50;
        finalOffsetX = baseOffsetX + (sizeDiff / 10) * 5;
        finalOffsetY = baseOffsetY - (sizeDiff / 10) * 10;
        break;
      case "palito_dd":
        baseOffsetX = 36;
        baseOffsetY = -45;
        finalOffsetX = baseOffsetX + (sizeDiff / 10) * 7;
        finalOffsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
        break;
      case "palito_de":
        baseOffsetX = 13;
        baseOffsetY = -45;
        finalOffsetX = baseOffsetX + (sizeDiff / 10) * 3;
        finalOffsetY = baseOffsetY - (sizeDiff / 10) * 9.5;
        break;
      case "palito_h":
        baseOffsetX = 48;
        baseOffsetY = -27;
        finalOffsetX = baseOffsetX + sizeDiff;
        finalOffsetY = baseOffsetY - (sizeDiff / 10) * 5;
        break;
    }

    return Offset(
      characterPosition.dx + finalOffsetX,
      characterPosition.dy + finalOffsetY,
    );
  }

  
  void addPalito(
      Offset position, String type, String semanticsLabel, double size) {
    const validTypes = ["palito_v", "palito_dd", "palito_de", "palito_h"];
    if (!validTypes.contains(type)) {
      throw ArgumentError("Tipo de palito inválido: $type");
    }
    final newPalito = Palito(
      position: position,
      type: type,
      semanticsLabel: semanticsLabel,
      size: size,
    );
    _palitos.add(newPalito);

    _edgesAlertedForPalito[newPalito] = <String>{};

    notifyListeners();
  }

  void removePalito(Palito palito) {
    _palitos.remove(palito);
    _edgesAlertedForPalito.remove(palito);
    notifyListeners();
  }

  void clearPalitos() {
    _palitos.clear();
    _edgesAlertedForPalito.clear();
    notifyListeners();
  }

  void checkAllPalitosOffscreen(
      BuildContext context, double screenWidth, double screenHeight) {
    for (final palito in _palitos) {
      final offscreenEdges =
          palito.getOffscreenEdges(screenWidth, screenHeight, context);

      final alertedEdges = _edgesAlertedForPalito[palito] ?? <String>{};

      for (final edge in offscreenEdges) {
        if (!alertedEdges.contains(edge)) {
          alertedEdges.add(edge);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("O palito '${palito.type}' saiu pela borda $edge!"),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }

      final edgesNoLongerOffscreen =
          alertedEdges.difference(offscreenEdges.toSet());

      for (final edge in edgesNoLongerOffscreen) {
        alertedEdges.remove(edge);
      }
      _edgesAlertedForPalito[palito] = alertedEdges;
    }
  }
}
