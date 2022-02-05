import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctions/stop_pop.dart';
import 'direct_pop.dart';

Future<void> customDialogBox({
  required BuildContext context,
  required bool isDialogShowing,
  required ValueChanged<bool> onIsDialogShowing,
  required bool barrierDismissible,
  required Widget dialogTitle,
  required Widget dialogChildren,
  required double screenBasedPixelWidth,
  required double screenBasedPixelHeight,
}) async {
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
          title: Center(child: dialogTitle),
          titlePadding: EdgeInsets.fromLTRB(screenBasedPixelWidth * 24.0,
              screenBasedPixelWidth * 24.0, screenBasedPixelWidth * 24.0, 0.0),
          contentPadding: EdgeInsets.fromLTRB(
              0.0,
              screenBasedPixelHeight * 12.0,
              0.0,
              screenBasedPixelHeight * 16.0),
          children: <Widget>[
            dialogChildren,
          ],
        ),
      );
    },
  );
}
