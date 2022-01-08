import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctions/stop_pop.dart';
import 'direct_pop.dart';

Future<void> processingDialog(
    {required BuildContext context,
    required bool isDialogShowing,
    required ValueChanged<bool> onIsDialogShowing,
    required bool barrierDismissible,
    required Widget dialogTitle,
    required Widget dialogChildren}) async {
  isDialogShowing = true; // set it `true` since dialog is being displayed
  onIsDialogShowing.call(isDialogShowing);
  await showDialog<bool>(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          return !barrierDismissible
              ? isDialogShowing
                  ? stopPop()
                  : directPop()
              : directPop();
        },
        child: SimpleDialog(
          title: dialogTitle,
          children: <Widget>[
            dialogChildren,
          ],
        ),
      );
    },
  );
}
