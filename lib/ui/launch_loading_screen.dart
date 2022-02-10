import 'dart:async';
import 'dart:math';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../basicFunctions/widget_size_limiter.dart';

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
  // double width = 1000;
  // double height = 300;
  Color textDialogOfLoginScreenColor = const Color(0xff04294f);

  ValueKey textOfLoginScreenValueKey = const ValueKey<int>(0);
  String textOfLoginScreen = "Connecting to\nVIT VTOP\nPlease Wait ...";

  Timer? timer;

  late Widget animationOfLoadingScreen;

  Widget actionButton = const SizedBox();

  Widget textDialogOfLoginScreen(
      {required String textOfLoginScreen,
      required Key textOfLoginScreenValueKey,
      required Color textDialogOfLoginScreenColor,
      required Widget actionButton}) {
    return AnimatedContainer(
      // height: height,
      // width: width,
      decoration: BoxDecoration(
        color: textDialogOfLoginScreenColor,
        //border: Border.all(color: Colors.blue, width: 10),
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
              Text(
                textOfLoginScreen,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: widgetSizeProvider(
                      fixedSize: 40,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
                key: textOfLoginScreenValueKey,
              ),
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
    // callTimerMethod();
    // callChangeTextMethod();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  var listOfColors = [
    const Color(0xff04294f),
    const Color(0xfff04e23),
    const Color(0xffffb400),
    const Color(0xff00acdc)
  ];
  // generates a new Random object
  final random = Random();

  Future<void> callTimerMethod() async {
    // Timer.periodic(const Duration(seconds: 3), (timer) {
    //   // generate a random index based on the list length
    //   // and use it to retrieve the element
    //   var element = listOfColors[random.nextInt(listOfColors.length)];
    //   setState(() {
    //     textDialogOfLoginScreenColor = element;
    //   });
    // });
  }

  callChangeTextMethod() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (widget.arguments.vtopConnectionStatusType == "Connecting") {
        // Before calling setState check if the state is mounted.
        if (mounted) {
          setState(() {
            textOfLoginScreen = "Connection is\ntaking longer\nthan usual";
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
        textOfLoginScreen = "Connecting to\nVIT VTOP\nPlease Wait ...";
        textOfLoginScreenValueKey = const ValueKey<int>(0);
        textDialogOfLoginScreenColor = const Color(0xff04294f);
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
        textOfLoginScreen = "Connection is\ntaking longer\nthan usual";
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
          textOfLoginScreen = "Connection failed\ndue to connection\ntimeout";
        } else {
          if (widget.arguments.vtopConnectionStatusErrorType ==
              "net::ERR_NAME_NOT_RESOLVED") {
            textOfLoginScreen =
                "Connection failed\nas website could\nnot be resolved";
          } else {
            if (widget.arguments.vtopConnectionStatusErrorType ==
                "net::ERR_INTERNET_DISCONNECTED") {
              textOfLoginScreen =
                  "Connection failed\nas your internet\nis disconnected";
            } else {
              textOfLoginScreen = "Connection failed";
            }
          }
        }
        textOfLoginScreenValueKey = const ValueKey<int>(3);
        textDialogOfLoginScreenColor = const Color(0xfff04e23);
        actionButton = ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
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
              TextStyle(
                fontSize: widgetSizeProvider(
                    fixedSize: 20,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
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
            children: [
              const Icon(Icons.refresh),
              Text(
                "Retry",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: widgetSizeProvider(
                      fixedSize: 17,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
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
        textOfLoginScreen =
            "Connection failed\nas something is\nwrong with VTOP";
        textOfLoginScreenValueKey = const ValueKey<int>(3);
        textDialogOfLoginScreenColor = const Color(0xfff04e23);
        actionButton = ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
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
              TextStyle(
                fontSize: widgetSizeProvider(
                    fixedSize: 20,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
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
            children: [
              const Icon(Icons.refresh),
              Text(
                "Retry",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: widgetSizeProvider(
                      fixedSize: 17,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
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
        textOfLoginScreen = "Successfully\nconnected\nto VTOP";
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

  LaunchLoadingScreenArguments({
    required this.vtopConnectionStatusType,
    required this.vtopConnectionStatusErrorType,
    required this.headlessWebView,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
