import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class LaunchLoadingScreen extends StatefulWidget {
  const LaunchLoadingScreen({
    Key? key,
    required this.arguments,
    required this.onCurrentFullUrl,
    required this.onRetryOnError,
  }) : super(key: key);

  final LaunchLoadingScreenArguments arguments;
  final ValueChanged<String> onCurrentFullUrl;
  final ValueChanged<bool> onRetryOnError;

  @override
  _LaunchLoadingScreenState createState() => _LaunchLoadingScreenState();
}

class _LaunchLoadingScreenState extends State<LaunchLoadingScreen> {
  Timer? timer;

  late Widget animationOfLoadingScreen;

  late Color textDialogOfLoginScreenColor;

  late ValueKey textOfLoginScreenValueKey;
  late Widget textOfLoginScreen;

  late Widget actionButton;

  Widget textDialogOfLoginScreen(
      {required Widget textOfLoginScreen,
      required Key textOfLoginScreenValueKey,
      required Color textDialogOfLoginScreenColor,
      required Widget actionButton}) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        color: textDialogOfLoginScreenColor,
        borderRadius: BorderRadius.all(
          Radius.circular(
            widgetSizeProvider(
                fixedSize: 40,
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          ),
        ),
      ),
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      child: Padding(
        padding: EdgeInsets.all(
          widgetSizeProvider(
              fixedSize: 20,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Column(
            children: [
              textOfLoginScreen,
              actionButton,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    animationOfLoadingScreen = Image.asset(
      "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Training_transparent_by_Icons8.gif",
      scale: 0.1,
      width: widgetSizeProvider(
          fixedSize: 5000,
          sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
      height: widgetSizeProvider(
          fixedSize: 5000,
          sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
      key: const ValueKey<int>(0),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    textDialogOfLoginScreenColor = Theme.of(context)
        .colorScheme
        .primaryContainer; // const Color(0xff04294f);

    textOfLoginScreenValueKey = const ValueKey<int>(0);
    textOfLoginScreen = Text(
      "Connecting to\nVIT VTOP\nPlease Wait ...",
      style: getDynamicTextStyle(
          textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
          sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
      textAlign: TextAlign.center,
      key: textOfLoginScreenValueKey,
    );

    actionButton = const SizedBox();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  callChangeTextMethod() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (widget.arguments.vtopConnectionStatusType == "Connecting") {
        // Before calling setState check if the state is mounted.
        if (mounted) {
          setState(() {
            textOfLoginScreen = Text(
              "Connection is\ntaking longer\nthan usual",
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.headline4,
                  sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
              textAlign: TextAlign.center,
              key: textOfLoginScreenValueKey,
            );
            textOfLoginScreenValueKey = const ValueKey<int>(1);
            textDialogOfLoginScreenColor = const Color(0xfffdb813);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.arguments.vtopConnectionStatusType == "Initiated") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Training_transparent_by_Icons8.gif",
          scale: 0.1,
          width: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          height: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          key: const ValueKey<int>(0),
        );
        textOfLoginScreen = Text(
          "Connecting to\nVIT VTOP\nPlease Wait ...",
          style: getDynamicTextStyle(
              textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          textAlign: TextAlign.center,
          key: textOfLoginScreenValueKey,
        );
        textOfLoginScreenValueKey = const ValueKey<int>(0);
        textDialogOfLoginScreenColor =
            Theme.of(context).colorScheme.primaryContainer;
        actionButton = const SizedBox();
      });
      debugPrint("widget.arguments.vtopErrorType");
    } else if (widget.arguments.vtopConnectionStatusType == "Connecting") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Training_transparent_by_Icons8.gif",
          scale: 0.1,
          width: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          height: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          key: const ValueKey<int>(0),
        );
        textOfLoginScreen = Text(
          "Connection is\ntaking longer\nthan usual",
          style: getDynamicTextStyle(
              textStyle: Theme.of(context).textTheme.headline4,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          textAlign: TextAlign.center,
          key: textOfLoginScreenValueKey,
        );
        textOfLoginScreenValueKey = const ValueKey<int>(1);
        textDialogOfLoginScreenColor = const Color(0xfffdb813);
        actionButton = const SizedBox();
      });
    } else if (widget.arguments.vtopConnectionStatusErrorType ==
            "net::ERR_CONNECTION_TIMED_OUT" ||
        widget.arguments.vtopConnectionStatusErrorType ==
            "net::ERR_NAME_NOT_RESOLVED" ||
        widget.arguments.vtopConnectionStatusErrorType ==
            "net::ERR_INTERNET_DISCONNECTED") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_No_Connection_transparent_by_Icons8.gif",
          scale: 0.1,
          width: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          height: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          key: const ValueKey<int>(1),
        );
        if (widget.arguments.vtopConnectionStatusErrorType ==
            "net::ERR_CONNECTION_TIMED_OUT") {
          textOfLoginScreen = Text(
            "Connection failed\ndue to connection\ntimeout",
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            textAlign: TextAlign.center,
            key: textOfLoginScreenValueKey,
          );
        } else {
          if (widget.arguments.vtopConnectionStatusErrorType ==
              "net::ERR_NAME_NOT_RESOLVED") {
            textOfLoginScreen = Text(
              "Connection failed\nas website could\nnot be resolved",
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                  sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
              textAlign: TextAlign.center,
              key: textOfLoginScreenValueKey,
            );
          } else {
            if (widget.arguments.vtopConnectionStatusErrorType ==
                "net::ERR_INTERNET_DISCONNECTED") {
              textOfLoginScreen = Text(
                "Connection failed\nas your internet\nis disconnected",
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                textAlign: TextAlign.center,
                key: textOfLoginScreenValueKey,
              );
            } else {
              textOfLoginScreen = Text(
                "Connection failed",
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                textAlign: TextAlign.center,
                key: textOfLoginScreenValueKey,
              );
            }
          }
        }
        textOfLoginScreenValueKey = const ValueKey<int>(3);
        textDialogOfLoginScreenColor =
            Theme.of(context).colorScheme.errorContainer;
        actionButton = ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).colorScheme.error),
            padding: MaterialStateProperty.all(
              EdgeInsets.only(
                top: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                bottom: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                left: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                right: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
            ),
            textStyle: MaterialStateProperty.all(
              getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.button,
                  sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  widgetSizeProvider(
                      fixedSize: 20,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                ),
              ),
            ),
          ),
          onPressed: () {
            // callChangeTextMethod();
            widget.onRetryOnError.call(true);
          },
          child: Row(
            children: const [
              Icon(Icons.refresh),
              Text(
                "Retry",
              )
            ],
          ),
        );
      });
      debugPrint("widget.arguments.vtopErrorType");
    } else if (widget.arguments.vtopConnectionStatusType == "Error") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_No_Connection_transparent_by_Icons8.gif",
          scale: 0.1,
          width: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          height: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          key: const ValueKey<int>(1),
        );
        textOfLoginScreen = Text(
          "Connection failed\nas something is\nwrong with VTOP",
          style: getDynamicTextStyle(
              textStyle: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          textAlign: TextAlign.center,
          key: textOfLoginScreenValueKey,
        );
        textOfLoginScreenValueKey = const ValueKey<int>(3);
        textDialogOfLoginScreenColor =
            Theme.of(context).colorScheme.errorContainer;
        actionButton = ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).colorScheme.error),
            padding: MaterialStateProperty.all(
              EdgeInsets.only(
                top: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                bottom: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                left: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                right: widgetSizeProvider(
                    fixedSize: 17,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
            ),
            textStyle: MaterialStateProperty.all(
              getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.button,
                  sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  widgetSizeProvider(
                      fixedSize: 20,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                ),
              ),
            ),
          ),
          onPressed: () {
            // callChangeTextMethod();
            widget.onRetryOnError.call(true);
          },
          child: Row(
            children: const [
              Icon(Icons.refresh),
              Text(
                "Retry",
              )
            ],
          ),
        );
      });
      debugPrint("widget.arguments.vtopErrorType");
    } else if (widget.arguments.vtopConnectionStatusType == "Connected") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Success_transparent_by_Icons8.gif",
          scale: 0.1,
          width: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          height: widgetSizeProvider(
              fixedSize: 5000,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          key: const ValueKey<int>(2),
        );
        textOfLoginScreen = Text(
          "Successfully\nconnected\nto VTOP",
          style: getDynamicTextStyle(
              textStyle: Theme.of(context).textTheme.headline4,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          textAlign: TextAlign.center,
          key: textOfLoginScreenValueKey,
        );
        textOfLoginScreenValueKey = const ValueKey<int>(4);
        textDialogOfLoginScreenColor = Colors.green;
        actionButton = const SizedBox();
      });
      debugPrint("widget.arguments.vtopErrorType");
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          widgetSizeProvider(
              fixedSize: 8,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: SizedBox(
                    height: widgetSizeProvider(
                        fixedSize: 250,
                        sizeDecidingVariable:
                            widget.arguments.screenBasedPixelWidth),
                    width: widgetSizeProvider(
                        fixedSize: 250,
                        sizeDecidingVariable:
                            widget.arguments.screenBasedPixelWidth),
                    child: animationOfLoadingScreen,
                  ),
                ),
              ),
              SizedBox(
                height: widgetSizeProvider(
                    fixedSize: 30,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: widgetSizeProvider(
                      fixedSize: 20,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  right: widgetSizeProvider(
                      fixedSize: 20,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        child: textDialogOfLoginScreen(
                          textOfLoginScreen: textOfLoginScreen,
                          textOfLoginScreenValueKey: textOfLoginScreenValueKey,
                          textDialogOfLoginScreenColor:
                              textDialogOfLoginScreenColor,
                          actionButton: actionButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LaunchLoadingScreenArguments {
  String vtopConnectionStatusType;
  String vtopConnectionStatusErrorType;
  HeadlessInAppWebView? headlessWebView;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;
  ValueChanged<bool> onProcessingSomething;

  LaunchLoadingScreenArguments({
    required this.vtopConnectionStatusType,
    required this.vtopConnectionStatusErrorType,
    required this.headlessWebView,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.onProcessingSomething,
  });
}
