import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/proccessing_dialog.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_elevated_button.dart';

class BuildCreditRow extends StatefulWidget {
  const BuildCreditRow({
    Key? key,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.onProcessingSomething,
    required this.creditToText,
    required this.creditUrl,
    required this.creditFor,
  }) : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final ValueChanged<bool> onProcessingSomething;
  final String creditFor;
  final String creditToText;
  final String creditUrl;

  @override
  _BuildCreditRowState createState() => _BuildCreditRowState();
}

class _BuildCreditRowState extends State<BuildCreditRow> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;
  late final double _screenBasedPixelHeight = widget.screenBasedPixelHeight;
  late final String _creditFor = widget.creditFor;
  late final String _creditToText = widget.creditToText;
  late final String _creditUrl = widget.creditUrl;

  final String dialogTextForForLeavingApp =
      'Do you want to leave the app to open the url?';
  late List<Widget> dialogActionButtonsListForLeavingApp;

  bool isDialogShowing = false;

  @override
  void didUpdateWidget(BuildCreditRow oldWidget) {
    if (oldWidget != widget) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    dialogActionButtonsListForLeavingApp = [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'No',
        ),
      ),
      CustomTextButton(
        onPressed: () {
          Navigator.pop(context);
          launch(_creditUrl);
        },
        screenBasedPixelWidth: _screenBasedPixelWidth,
        screenBasedPixelHeight: _screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'Yes',
        ),
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            _creditFor,
            overflow: TextOverflow.ellipsis,
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: _screenBasedPixelWidth),
          ),
        ),
        Flexible(
          flex: 1,
          child: RichText(
            text: TextSpan(
              text: _creditToText,
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  sizeDecidingVariable: _screenBasedPixelWidth),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  customAlertDialogBox(
                    context: context,
                    isDialogShowing: isDialogShowing,
                    onIsDialogShowing: (bool value) {
                      setState(() {
                        isDialogShowing = value;
                      });
                    },
                    barrierDismissible: true,
                    dialogTitle: Text(
                      'Leave App',
                      style: getDynamicTextStyle(
                          textStyle: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.87)),
                          sizeDecidingVariable: _screenBasedPixelWidth),
                      textAlign: TextAlign.center,
                    ),
                    dialogContent: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dialogTextForForLeavingApp,
                            style: getDynamicTextStyle(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.60)),
                                sizeDecidingVariable: _screenBasedPixelWidth),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    dialogActions: dialogActionButtonsListForLeavingApp,
                    screenBasedPixelWidth: _screenBasedPixelWidth,
                    screenBasedPixelHeight: _screenBasedPixelHeight,
                    onProcessingSomething: (bool value) {
                      widget.onProcessingSomething.call(value);
                    },
                  ).then((_) => isDialogShowing = false);
                },
            ),
          ),
        ),
      ],
    );
  }
}
