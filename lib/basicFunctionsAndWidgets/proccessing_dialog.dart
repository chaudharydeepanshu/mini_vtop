import 'dart:async';

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
  ValueChanged<StateSetter>? onSetState,
}) async {
  isDialogShowing = true; // set it `true` since dialog is being displayed
  onIsDialogShowing.call(isDialogShowing);
  await showDialog<bool>(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (BuildContext context) {
      return DialogBox(
        onProcessingSomething: onProcessingSomething,
        dialogTitle: dialogTitle,
        dialogChildren: dialogChildren,
        isDialogShowing: isDialogShowing,
        barrierDismissible: barrierDismissible,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        onSetState: onSetState,
      );
    },
  );
}

class DialogBox extends StatefulWidget {
  const DialogBox({
    Key? key,
    required this.barrierDismissible,
    required this.isDialogShowing,
    required this.onProcessingSomething,
    required this.dialogTitle,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.dialogChildren,
    this.onSetState,
  }) : super(key: key);

  final bool barrierDismissible;
  final bool isDialogShowing;
  final ValueChanged<bool> onProcessingSomething;

  final Widget dialogTitle;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final Widget dialogChildren;
  final ValueChanged<StateSetter>? onSetState;

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  @override
  void didUpdateWidget(DialogBox oldWidget) {
    if (oldWidget != widget) {
      setState(() {
        _widget = widget;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  late DialogBox _widget = widget;

  @override
  Widget build(BuildContext context) {
    _widget.onSetState?.call(setState);
    return WillPopScope(
      onWillPop: () {
        return !_widget.barrierDismissible
            ? _widget.isDialogShowing
                ? stopPop()
                : directPop(onProcessingSomething: (bool value) {
                    _widget.onProcessingSomething.call(value);
                  })
            : directPop(onProcessingSomething: (bool value) {
                _widget.onProcessingSomething.call(value);
              });
      },
      child: SimpleDialog(
        title: Center(child: _widget.dialogTitle),
        titlePadding: EdgeInsets.fromLTRB(
          widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 0,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
        ),
        contentPadding: EdgeInsets.fromLTRB(
          widgetSizeProvider(
              fixedSize: 0,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 12,
              sizeDecidingVariable: _widget.screenBasedPixelHeight),
          widgetSizeProvider(
              fixedSize: 0,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 16,
              sizeDecidingVariable: _widget.screenBasedPixelHeight),
        ),
        insetPadding: EdgeInsets.fromLTRB(
          widgetSizeProvider(
              fixedSize: 0,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 12,
              sizeDecidingVariable: _widget.screenBasedPixelHeight),
          widgetSizeProvider(
              fixedSize: 0,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          widgetSizeProvider(
              fixedSize: 16,
              sizeDecidingVariable: _widget.screenBasedPixelHeight),
        ),
        children: <Widget>[
          _widget.dialogChildren,
        ],
      ),
    );
  }
}
