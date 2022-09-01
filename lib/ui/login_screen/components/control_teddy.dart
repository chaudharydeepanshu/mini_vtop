import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class ControlTeddy {
  // Trigger for password fail.
  SMITrigger? _fail;

  // Trigger for password success.
  SMITrigger? _success;

  // Boolean input for covering eyes.
  SMIBool? _handsUp;

  // Boolean input for enabling text field following eyes.
  SMIBool? _check;

  // Input for changing eyes position on x axis.
  SMIInput<double>? _look;

  // Function fired when Riveanimation has initialized.
  void onRiveInit(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      _fail = controller.findInput<bool>('fail') as SMITrigger?;
      _success = controller.findInput<bool>('success') as SMITrigger?;
      _handsUp = controller.findInput<bool>('hands_up') as SMIBool?;
      _look = controller.findInput<double>('Look');
      _check = controller.findInput<bool>('Check') as SMIBool?;
    }
  }

  String password = '';

  // Boolean status of eyes covering.
  bool _isCoveringEyes = false;

  // Controls Teddy eyes using offset of text field cursor and text field size.
  void lookAt({required Offset? caret, required Size? textFieldSize}) {
    if (caret != null && textFieldSize != null) {
      _check?.value = true;
      _look?.value = caret.dx - textFieldSize.width / 2;
    } else {
      _check?.value = false;
    }
  }

  // Used to cover Teddy eyes when entering password.
  void coverEyes({required bool cover}) {
    if (_isCoveringEyes == cover) {
      return;
    }
    _isCoveringEyes = cover;
    if (cover) {
      _handsUp?.value = true;
    } else {
      _handsUp?.value = false;
      _isCoveringEyes = false;
    }
  }

  // Function fired when clicking Sign In button.
  void submitPassword() {
    if (password == "bears") {
      _success?.fire();
    } else {
      _fail?.fire();
    }
  }
}
