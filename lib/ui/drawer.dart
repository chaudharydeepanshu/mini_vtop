import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/custom_elevated_button.dart';
import 'package:mini_vtop/coreFunctions/sign_out.dart';
import 'package:mini_vtop/ui/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'package:html/dom.dart' as dom;
import '../navigation/page_routes_model.dart';

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
    required this.onThemeMode,
    this.onShowStudentProfileAllView,
    this.onTryAutoLoginStatus,
    required this.processingSomething,
    required this.onError,
    required this.onProcessingSomething,
    required this.timeTableDocument,
    required this.semesterSubIdForTimeTable,
    required this.onRequestType,
    required this.onUpdateDefaultTimeTableSemesterId,
    required this.onUpdateDefaultVtopMode,
    required this.onUpdateVtopMode,
    required this.vtopMode,
    required this.loggedUserStatus,
    required this.onLoggedUserStatus,
    required this.onTimeTableAndAttendance,
    required this.classAttendanceDocument,
    required this.semesterSubIdForAttendance,
    required this.onUpdateDefaultAttendanceSemesterId,
  }) : super(key: key);
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeMode;
  final String currentStatus;
  final String? loggedUserStatus;
  final ValueChanged<String> onCurrentStatus;
  final ValueChanged<String> onLoggedUserStatus;
  final HeadlessInAppWebView? headlessWebView;
  final ValueChanged<String> onCurrentFullUrl;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final bool processingSomething;
  final ValueChanged<bool>? onTimeTableAndAttendance;
  final ValueChanged<bool>? onShowStudentProfileAllView;
  final ValueChanged<bool>? onTryAutoLoginStatus;
  final ValueChanged<String> onError;
  final ValueChanged<bool> onProcessingSomething;
  final dom.Document? timeTableDocument;
  final dom.Document? classAttendanceDocument;
  final String semesterSubIdForTimeTable;
  final String semesterSubIdForAttendance;
  final String vtopMode;
  final ValueChanged<String> onRequestType;
  final ValueChanged<String> onUpdateDefaultTimeTableSemesterId;
  final ValueChanged<String> onUpdateDefaultAttendanceSemesterId;
  final ValueChanged<String> onUpdateDefaultVtopMode;

  final ValueChanged<String> onUpdateVtopMode;

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
    if (oldWidget.themeMode != widget.themeMode) {
      themeButtonTextCalc();
    }

    super.didUpdateWidget(oldWidget);
  }

  runRequestingSettingsDialogBox() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onProcessingSomething.call(
          true); //then set processing something true for the new loading dialog
      customAlertDialogBox(
        isDialogShowing: isDialogShowing,
        context: context,
        onIsDialogShowing: (bool value) {
          setState(() {
            isDialogShowing = value;
          });
        },
        dialogTitle: 'Preparing Settings',
        dialogContent: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: widgetSizeProvider(
                  fixedSize: 36, sizeDecidingVariable: screenBasedPixelWidth),
              width: widgetSizeProvider(
                  fixedSize: 36, sizeDecidingVariable: screenBasedPixelWidth),
              child: CircularProgressIndicator(
                strokeWidth: widgetSizeProvider(
                    fixedSize: 4, sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
            Text(
              'Please wait...',
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.60)),
                  sizeDecidingVariable: screenBasedPixelWidth),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        barrierDismissible: true,
        screenBasedPixelHeight: screenBasedPixelHeight,
        screenBasedPixelWidth: screenBasedPixelWidth,
        onProcessingSomething: (bool value) {
          widget.onProcessingSomething.call(value);
        },
      ).then((_) {
        widget.onProcessingSomething.call(false);
        return isDialogShowing = false;
      });
    });
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

  bool isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    debugPrint("themeButtonText $themeButtonText");
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
                                  alignment: Alignment.center,
                                  semanticsLabel: 'App Logo'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: widgetSizeProvider(
                        fixedSize: 8,
                        sizeDecidingVariable: screenBasedPixelHeight),
                  ),
                  child: CustomElevatedButton(
                    onPressed: () {
                      // toggling the theme mode in this sequence system -> light -> dark
                      if (widget.themeMode == ThemeMode.light) {
                        widget.onThemeMode?.call(ThemeMode.dark);
                      } else if (widget.themeMode == ThemeMode.dark) {
                        widget.onThemeMode?.call(ThemeMode.system);
                      } else if (widget.themeMode == ThemeMode.system) {
                        widget.onThemeMode?.call(ThemeMode.light);
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          'Theme Mode - $themeButtonText',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    screenBasedPixelWidth: screenBasedPixelWidth,
                    screenBasedPixelHeight: screenBasedPixelHeight,
                    borderRadius: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                ),
                Column(
                  children: [
                    (_currentStatus != "signInScreen" &&
                            _currentStatus != "launchLoadingScreen")
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: widgetSizeProvider(
                                  fixedSize: 8,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                            ),
                            child: CustomElevatedButton(
                              onPressed: () {
                                // Update the state of the app
                                if (vtopCurrentStatusText == "Mini VTOP") {
                                  // making a fake call to StudentProfileAllView so that
                                  // if the user gets logged out it will automatically restart the webview
                                  widget.onShowStudentProfileAllView
                                      ?.call(true);
                                  _currentStatus = "originalVTOP";
                                  widget.onUpdateVtopMode.call("Full VTOP");
                                  // widget.onCurrentStatus.call("originalVTOP");
                                } else if (vtopCurrentStatusText ==
                                    "Full VTOP") {
                                  // making a fake call to StudentProfileAllView so that
                                  // if the user gets logged out it will automatically restart the webview
                                  widget.onShowStudentProfileAllView
                                      ?.call(true);
                                  _currentStatus = "userLoggedIn";
                                  widget.onUpdateVtopMode.call("Mini VTOP");
                                }
                                vtopModeButtonTextCalc();
                                // Then close the drawer
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'VTOP Mode - $vtopCurrentStatusText',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              screenBasedPixelWidth: screenBasedPixelWidth,
                              screenBasedPixelHeight: screenBasedPixelHeight,
                              borderRadius: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                            ),
                          )
                        : const SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: widgetSizeProvider(
                            fixedSize: 8,
                            sizeDecidingVariable: screenBasedPixelWidth),
                      ),
                      child: CustomElevatedButton(
                        onPressed: () {
                          // Update the state of the app
                          // making a fake call to StudentProfileAllView so that
                          // if the user gets logged out it will automatically restart the webview
                          // widget.onShowStudentProfileAllView?.call(true);

                          // Then close the drawer
                          Navigator.pop(context);

                          if (_currentStatus != "signInScreen" &&
                              _currentStatus != "launchLoadingScreen") {
                            widget.onTimeTableAndAttendance?.call(true);
                            runRequestingSettingsDialogBox();
                          } else {
                            Navigator.pushNamed(
                              context,
                              PageRoutes.settings,
                              arguments: SettingsArguments(
                                currentStatus: widget.currentStatus,
                                onWidgetDispose: (bool value) {
                                  debugPrint("settings disposed");
                                  WidgetsBinding.instance?.addPostFrameCallback(
                                    (_) => widget.onLoggedUserStatus
                                        .call("studentPortalScreen"),
                                  );
                                },
                                timeTableDocument: widget.timeTableDocument,
                                classAttendanceDocument:
                                    widget.classAttendanceDocument,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                semesterSubIdForTimeTable:
                                    widget.semesterSubIdForTimeTable,
                                semesterSubIdForAttendance:
                                    widget.semesterSubIdForAttendance,
                                onSemesterSubIdForTimeTableChange:
                                    (String value) {},
                                onSemesterSubIdForAttendanceChange:
                                    (String value) {},
                                onProcessingSomething: (bool value) {
                                  widget.onProcessingSomething.call(value);
                                },
                                onUpdateDefaultTimeTableSemesterId:
                                    (String value) {
                                  widget.onUpdateDefaultTimeTableSemesterId
                                      .call(value);
                                },
                                onUpdateDefaultAttendanceSemesterId:
                                    (String value) {
                                  widget.onUpdateDefaultAttendanceSemesterId
                                      .call(value);
                                },
                                vtopMode: widget.vtopMode,
                                onUpdateDefaultVtopMode: (String value) {
                                  widget.onUpdateDefaultVtopMode.call(value);
                                },
                                headlessWebView: widget.headlessWebView,
                                processingSomething: widget.processingSomething,
                              ),
                            );
                            widget.onLoggedUserStatus.call("settings");
                          }
                        },
                        child: Row(
                          children: const [
                            Text(
                              'Settings',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        screenBasedPixelWidth: screenBasedPixelWidth,
                        screenBasedPixelHeight: screenBasedPixelHeight,
                        borderRadius: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                      ),
                    ),
                    (_currentStatus != "signInScreen" &&
                            _currentStatus != "launchLoadingScreen")
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: widgetSizeProvider(
                                  fixedSize: 8,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                            ),
                            child: CustomElevatedButton(
                              onPressed: () {
                                widget.onTryAutoLoginStatus?.call(false);
                                performSignOut(
                                  context: context,
                                  headlessWebView: widget.headlessWebView,
                                  onCurrentFullUrl: (String value) {
                                    widget.onCurrentFullUrl.call(value);
                                  },
                                  onError: (String value) {
                                    widget.onError.call(value);
                                  },
                                );
                                // Then close the drawer
                                Navigator.pop(context);

                                WidgetsBinding.instance
                                    ?.addPostFrameCallback((_) {
                                  widget.onProcessingSomething.call(
                                      true); //then set processing something true for the new loading dialog
                                  customAlertDialogBox(
                                    isDialogShowing: isDialogShowing,
                                    context: context,
                                    onIsDialogShowing: (bool value) {
                                      setState(() {
                                        isDialogShowing = value;
                                      });
                                    },
                                    dialogTitle: 'Processing logout',
                                    dialogContent: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: widgetSizeProvider(
                                              fixedSize: 36,
                                              sizeDecidingVariable:
                                                  screenBasedPixelWidth),
                                          width: widgetSizeProvider(
                                              fixedSize: 36,
                                              sizeDecidingVariable:
                                                  screenBasedPixelWidth),
                                          child: CircularProgressIndicator(
                                            strokeWidth: widgetSizeProvider(
                                                fixedSize: 4,
                                                sizeDecidingVariable:
                                                    screenBasedPixelWidth),
                                          ),
                                        ),
                                        Text(
                                          'Please wait...',
                                          style: TextStyle(
                                            fontSize: widgetSizeProvider(
                                                fixedSize: 20,
                                                sizeDecidingVariable:
                                                    screenBasedPixelWidth),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    barrierDismissible: true,
                                    screenBasedPixelHeight:
                                        screenBasedPixelHeight,
                                    screenBasedPixelWidth:
                                        screenBasedPixelWidth,
                                    onProcessingSomething: (bool value) {
                                      widget.onProcessingSomething.call(value);
                                    },
                                  ).then((_) {
                                    widget.onProcessingSomething.call(false);
                                    return isDialogShowing = false;
                                  });
                                });
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    'Logout',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              screenBasedPixelWidth: screenBasedPixelWidth,
                              screenBasedPixelHeight: screenBasedPixelHeight,
                              borderRadius: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: widgetSizeProvider(
                  fixedSize: 8, sizeDecidingVariable: screenBasedPixelWidth),
              right: widgetSizeProvider(
                  fixedSize: 8, sizeDecidingVariable: screenBasedPixelWidth),
            ),
            child: Column(
              children: [
                // Commented out as currently there is no privacy policy.
                // RichText(
                //   text: TextSpan(
                //     text: 'Privacy Policy',
                //     style: getDynamicTextStyle(
                //         textStyle: Theme.of(context)
                //             .textTheme
                //             .bodyText1
                //             ?.copyWith(
                //               color: Theme.of(context).colorScheme.secondary,
                //             ),
                //         sizeDecidingVariable: screenBasedPixelWidth),
                //     recognizer: TapGestureRecognizer()
                //       ..onTap = () {
                //         leavingAppDialogBox(
                //             actionButtonsList:
                //                 dialogActionButtonsListForLeavingApp,
                //             text: dialogTextForForLeavingApp,
                //             context: context);
                //       },
                //   ),
                // ),
                packageInfo != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: widgetSizeProvider(
                              fixedSize: 8,
                              sizeDecidingVariable: screenBasedPixelWidth),
                          top: widgetSizeProvider(
                              fixedSize: 8,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "App Version - $version+$buildNumber",
                              style: getDynamicTextStyle(
                                  textStyle:
                                      Theme.of(context).textTheme.bodyText2,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
