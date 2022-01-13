import 'dart:async';
import 'dart:math';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  BorderRadiusGeometry textDialogOfLoginScreenBorderRadius =
      const BorderRadius.all(Radius.circular(40));

  ValueKey textOfLoginScreenValueKey = const ValueKey<int>(0);
  String textOfLoginScreen = "Connecting to\nVIT VTOP\nPlease Wait ...";

  Timer? timer;

  Widget animationOfLoadingScreen = Image.asset(
    "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Training_transparent_by_Icons8.gif",
    scale: 0.1,
    width: 5000,
    height: 5000,
    key: const ValueKey<int>(0),
  );

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
        borderRadius: textDialogOfLoginScreenBorderRadius,
      ),
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  fontSize: 40,
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
      if (widget.arguments.vtopStatusType == "Connecting") {
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
    if (widget.arguments.vtopStatusType == "null") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Training_transparent_by_Icons8.gif",
          scale: 0.1,
          width: 5000,
          height: 5000,
          key: const ValueKey<int>(0),
        );
        textOfLoginScreen = "Connecting to\nVIT VTOP\nPlease Wait ...";
        textOfLoginScreenValueKey = const ValueKey<int>(0);
        textDialogOfLoginScreenColor = const Color(0xff04294f);
        actionButton = const SizedBox();
      });
      debugPrint("widget.arguments.vtopErrorType");
    } else if (widget.arguments.vtopStatusType == "Connecting") {
      setState(() {
        textOfLoginScreen = "Connection is\ntaking longer\nthan usual";
        textOfLoginScreenValueKey = const ValueKey<int>(1);
        textDialogOfLoginScreenColor = const Color(0xfffdb813);
      });
    } else if (widget.arguments.vtopStatusType ==
        "net::ERR_CONNECTION_TIMED_OUT") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_No_Connection_transparent_by_Icons8.gif",
          scale: 0.1,
          width: 5000,
          height: 5000,
          key: const ValueKey<int>(1),
        );
        textOfLoginScreen =
            "Connection failed\nas something is\nwrong with VTOP";
        textOfLoginScreenValueKey = const ValueKey<int>(3);
        textDialogOfLoginScreenColor = const Color(0xfff04e23);
        actionButton = ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
            padding: MaterialStateProperty.all(const EdgeInsets.only(
                top: 17, bottom: 17, left: 17, right: 17)),
            textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              )
            ],
          ),
        );
      });
      debugPrint("widget.arguments.vtopErrorType");
    } else if (widget.arguments.vtopStatusType == "Connected") {
      setState(() {
        animationOfLoadingScreen = Image.asset(
          "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Success_transparent_by_Icons8.gif",
          scale: 0.1,
          width: 5000,
          height: 5000,
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
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: animationOfLoadingScreen,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
    );
  }
}

class LaunchLoadingScreenArguments {
  String? vtopStatusType;
  HeadlessInAppWebView? headlessWebView;

  LaunchLoadingScreenArguments({
    required this.vtopStatusType,
    required this.headlessWebView,
  });
}
