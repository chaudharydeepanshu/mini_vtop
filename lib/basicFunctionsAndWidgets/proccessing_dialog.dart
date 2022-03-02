import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/stop_pop.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';
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
  required ValueChanged<bool> onProcessingSomething,
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
                  : directPop(onProcessingSomething: (bool value) {
                      onProcessingSomething.call(value);
                    })
              : directPop(onProcessingSomething: (bool value) {
                  onProcessingSomething.call(value);
                });
        },
        child: SimpleDialog(
          title: Center(child: dialogTitle),
          titlePadding: EdgeInsets.fromLTRB(
            widgetSizeProvider(
                fixedSize: 24, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 24, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 24, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
          ),
          contentPadding: EdgeInsets.fromLTRB(
            widgetSizeProvider(
                fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 12, sizeDecidingVariable: screenBasedPixelHeight),
            widgetSizeProvider(
                fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 16, sizeDecidingVariable: screenBasedPixelHeight),
          ),
          insetPadding: EdgeInsets.fromLTRB(
            widgetSizeProvider(
                fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 12, sizeDecidingVariable: screenBasedPixelHeight),
            widgetSizeProvider(
                fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
            widgetSizeProvider(
                fixedSize: 16, sizeDecidingVariable: screenBasedPixelHeight),
          ),
          children: <Widget>[
            dialogChildren,
          ],
        ),
      );
    },
  );
}
