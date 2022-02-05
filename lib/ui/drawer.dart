import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mini_vtop/coreFunctions/sign_out.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../basicFunctions/dailog_box_for_leaving_app.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    Key? key,
    required this.themeMode,
    required this.currentStatus,
    required this.onCurrentStatus,
    required this.headlessWebView,
    required this.onCurrentFullUrl,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.onthemeMode,
  }) : super(key: key);
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onthemeMode;
  final String currentStatus;
  final ValueChanged<String> onCurrentStatus;
  final HeadlessInAppWebView? headlessWebView;
  final ValueChanged<String> onCurrentFullUrl;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? previousTheme;
  String? themeButtonText;
  String? vtopCurrentStatusText;
  late String _currentStatus;

  @override
  void didUpdateWidget(CustomDrawer oldWidget) {
    if (oldWidget.currentStatus != widget.currentStatus) {
      _currentStatus = widget.currentStatus;
    }

    super.didUpdateWidget(oldWidget);
  }

  vtopModeButtonTextCalc() async {
    if (_currentStatus == "launchLoadingScreen") {
      setState(() {
        vtopCurrentStatusText = "Loading Screen";
      });
    } else if (_currentStatus == "signInScreen") {
      setState(() {
        vtopCurrentStatusText = "Sign In";
      });
    } else if (_currentStatus == "userLoggedIn") {
      setState(() {
        vtopCurrentStatusText = "Mini VTOP";
      });
    } else if (_currentStatus == "originalVTOP") {
      setState(() {
        vtopCurrentStatusText = "Full VTOP";
      });
    }
    debugPrint(_currentStatus);
  }

  themeButtonTextCalc() async {
    if (widget.themeMode == ThemeMode.light) {
      setState(() {
        themeButtonText = "Light";
      });
    } else if (widget.themeMode == ThemeMode.dark) {
      setState(() {
        themeButtonText = "Dark";
      });
    } else if (widget.themeMode == ThemeMode.system) {
      setState(() {
        themeButtonText = "System";
      });
    }
  }

  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  packageInfoCalc() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo!.appName;
      packageName = packageInfo!.packageName;
      version = packageInfo!.version;
      buildNumber = packageInfo!.buildNumber;
    });
  }

  List<Widget>? dialogActionButtonsListForLeavingApp;
  String? dialogTextForForLeavingApp;

  @override
  void initState() {
    screenBasedPixelWidth = widget.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.screenBasedPixelHeight;
    _currentStatus = widget.currentStatus;
    vtopModeButtonTextCalc();
    packageInfoCalc();
    dialogActionButtonsListForLeavingApp = [
      OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('No'),
      ),
      OutlinedButton(
        onPressed: () async {
          Navigator.pop(context);
          launch('https://google.com/');
        },
        child: const Text('Yes'),
      ),
    ];
    dialogTextForForLeavingApp =
        'You are leaving the app to open the privacy policy url. So, please confirm that do you want to leave the app?';

    super.initState();
  }

  @override
  void didChangeDependencies() {
    themeButtonTextCalc(); // calling here as buttonTextCalc need context for localization of app
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    themeButtonTextCalc();
    debugPrint(themeButtonText);
    debugPrint(
        "brightness.name: ${WidgetsBinding.instance!.window.platformBrightness}");
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                        //color: Colors.white,
                        ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 1, minHeight: 1),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/images/logos/logo.svg',
                                  // fit: BoxFit.fitHeight,
                                  color: ((WidgetsBinding.instance!.window
                                                      .platformBrightness ==
                                                  Brightness.dark &&
                                              themeButtonText == 'System') ||
                                          (themeButtonText == 'Dark'))
                                      ? Colors.white
                                      : Colors.black,
                                  // height: 100,
                                  alignment: Alignment.center,
                                  semanticsLabel: 'App Logo'),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // const Text(
                              //   'Mini VTOP',
                              //   style: TextStyle(fontSize: 20),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenBasedPixelWidth * 8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: MaterialStateProperty.all<Size?>(
                        Size.fromHeight(screenBasedPixelHeight * 56),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff04294f)),
                      padding: MaterialStateProperty.all(EdgeInsets.only(
                          left: screenBasedPixelWidth * 20,
                          right: screenBasedPixelWidth * 20)),
                      textStyle: MaterialStateProperty.all(
                          TextStyle(fontSize: screenBasedPixelWidth * 20)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenBasedPixelWidth * 0.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // toggling the theme mode in this sequence system -> light -> dark
                      if (widget.themeMode == ThemeMode.light) {
                        widget.onthemeMode?.call(ThemeMode.dark);
                      } else if (widget.themeMode == ThemeMode.dark) {
                        widget.onthemeMode?.call(ThemeMode.system);
                      } else if (widget.themeMode == ThemeMode.system) {
                        widget.onthemeMode?.call(ThemeMode.light);
                      }
                      // Then close the drawer
                      //Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          'Theme Mode - $themeButtonText',
                          style:
                              TextStyle(fontSize: screenBasedPixelWidth * 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                (vtopCurrentStatusText != "Sign In" &&
                        vtopCurrentStatusText != "Loading Screen")
                    ? Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: screenBasedPixelWidth * 8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: MaterialStateProperty.all<Size?>(
                                  Size.fromHeight(screenBasedPixelHeight * 56),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff04294f)),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.only(
                                        left: screenBasedPixelWidth * 20,
                                        right: screenBasedPixelWidth * 20)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: screenBasedPixelWidth * 20)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenBasedPixelWidth * 0.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                // Update the state of the app
                                if (vtopCurrentStatusText == "Mini VTOP") {
                                  _currentStatus = "originalVTOP";
                                  widget.onCurrentStatus.call("originalVTOP");
                                } else if (vtopCurrentStatusText ==
                                    "Full VTOP") {
                                  _currentStatus = "userLoggedIn";
                                  widget.onCurrentStatus.call("userLoggedIn");
                                }
                                vtopModeButtonTextCalc();
                                // Then close the drawer
                                // Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'VTOP Mode - $vtopCurrentStatusText',
                                    style: TextStyle(
                                        fontSize: screenBasedPixelWidth * 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: screenBasedPixelWidth * 8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: MaterialStateProperty.all<Size?>(
                                  Size.fromHeight(screenBasedPixelHeight * 56),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff04294f)),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.only(
                                        left: screenBasedPixelWidth * 20,
                                        right: screenBasedPixelWidth * 20)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: screenBasedPixelWidth * 20)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenBasedPixelWidth * 0.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                performSignOut(
                                    context: context,
                                    headlessWebView: widget.headlessWebView,
                                    onCurrentFullUrl: (String value) {
                                      widget.onCurrentFullUrl.call(value);
                                    });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontSize: screenBasedPixelWidth * 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                  left: screenBasedPixelWidth * 8.0,
                  right: screenBasedPixelWidth * 8.0),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          fontSize: screenBasedPixelWidth * 16,
                          color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          leavingAppDialogBox(
                              actionButtonsList:
                                  dialogActionButtonsListForLeavingApp,
                              text: dialogTextForForLeavingApp,
                              context: context);
                        },
                    ),
                  ),
                  packageInfo != null
                      ? Padding(
                          padding: EdgeInsets.only(
                              bottom: screenBasedPixelWidth * 8.0,
                              top: screenBasedPixelWidth * 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "App Version - $version+$buildNumber",
                                style: TextStyle(
                                  fontSize: screenBasedPixelWidth * 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
