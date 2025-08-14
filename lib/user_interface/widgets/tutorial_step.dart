import 'package:flutter/material.dart';

enum TutorialPhase { 
  manual, 
  autoJump,
  singlePhase 
}

class TutorialStep {
  final GlobalKey targetKey;
  final String instruction;
  final String? palitoType; 
  final Function? movementAction; 

  TutorialStep({
    required this.targetKey,
    required this.instruction,
    this.palitoType,
    this.movementAction,
  });
}