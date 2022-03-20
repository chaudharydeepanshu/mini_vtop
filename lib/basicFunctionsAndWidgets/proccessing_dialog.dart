import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/stop_pop.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'direct_pop.dart';

Future<void> customAlertDialogBox({
  required BuildContext context,
  required bool isDialogShowing,
  required ValueChanged<bool> onIsDialogShowing,
  required bool barrierDismissible,
  required String dialogTitle,
  required Widget dialogContent,
  List<Widget>? dialogActions,
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
        dialogContent: dialogContent,
        dialogActions: dialogActions,
        isDialogShowing: isDialogShowing,
        barrierDismissible: barrierDismissible,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        // onSetState: onSetState,
        context: context,
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
    required this.dialogContent,
    // this.onSetState,
    this.dialogActions,
    required this.context,
  }) : super(key: key);

  final bool barrierDismissible;
  final bool isDialogShowing;
  final ValueChanged<bool> onProcessingSomething;
  final BuildContext context;
  final String dialogTitle;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final Widget dialogContent;
  final List<Widget>? dialogActions;
  // final ValueChanged<StateSetter>? onSetState;

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
    // _widget.onSetState?.call(setState);
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
      child: AlertDialog(
        title: Center(
          child: Text(
            _widget.dialogTitle,
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87)),
                sizeDecidingVariable: _widget.screenBasedPixelWidth),
            textAlign: TextAlign.center,
          ),
        ),
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
        insetPadding: EdgeInsets.symmetric(
          horizontal: widgetSizeProvider(
              fixedSize: 40,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
          vertical: widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: _widget.screenBasedPixelWidth),
        ),
        content: _widget.dialogContent,
        actions: _widget.dialogActions,
      ),
    );
  }
}
