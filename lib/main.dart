//todo: choose correct asset type to apks like armX64 etc in future
//todo: Clear old apks from app cache at start
//todo: decrease animation size
//todo: use predefined themes for text everywhere
//todo: add overflow ellipses property to texts
//todo: create disable battery optimization and run in background in settings
//todo: fix the stuttering transition when changing VTOP full mode to VTOP mini mode

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mini_vtop/coreFunctions/call_class_attendance.dart';
import 'package:mini_vtop/coreFunctions/choose_correct_initial_appbar.dart';
import 'package:mini_vtop/coreFunctions/manage_user_session.dart';
import 'package:mini_vtop/sharedPreferences/app_theme_shared_preferences.dart';
import 'package:mini_vtop/ui/AppTheme/app_theme_data.dart';
import 'package:mini_vtop/ui/class_attendance.dart';
import 'package:mini_vtop/ui/settings.dart';
import 'package:mini_vtop/ui/student_profile_all_view.dart';
import 'package:mini_vtop/ui/time_table.dart';
import 'package:ntp/ntp.dart';
import 'package:open_settings/open_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'basicFunctionsAndWidgets/custom_elevated_button.dart';
import 'basicFunctionsAndWidgets/update/build_update_checker_widget.dart';
import 'basicFunctionsAndWidgets/dismiss_keyboard.dart';
import 'basicFunctionsAndWidgets/print_wrapped.dart';
import 'basicFunctionsAndWidgets/proccessing_dialog.dart';
import 'basicFunctionsAndWidgets/widget_size_limiter.dart';
import 'browser/models/browser_model.dart';
import 'browser/models/webview_model.dart';
import 'coreFunctions/auto_captcha.dart';
import 'coreFunctions/call_time_table.dart';
import 'coreFunctions/choose_correct_drawer.dart';
import 'coreFunctions/choose_correct_initial_body.dart';
import 'coreFunctions/forHeadlessInAppWebView/headless_web_view.dart';
import 'coreFunctions/forHeadlessInAppWebView/run_headless_in_app_web_view.dart';
import 'coreFunctions/sign_out.dart';
import 'navigation/page_routes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
late final dynamic webArchiveDir;

late final dynamic tabViewerBottomOffset1;
late final dynamic tabViewerBottomOffset2;
late final dynamic tabViewerBottomOffset3;

const tabViewerTopOffset1 = 0.0;
const tabViewerTopOffset2 = 10.0;
const tabViewerTopOffset3 = 20.0;

const tabViewerTopScaleTopOffset = 250.0;
const tabViewerTopScaleBottomOffset = 230.0;

class TestClass {
  static void callback(String id, DownloadTaskStatus status, int progress) {}
}
// ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑

Future main() async {
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('assets/google_fonts/montserrat/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  int? retrieveSavedThemeModeIndex = await retrieveSavedThemeMode();
  final ThemeMode savedThemeMode = retrieveSavedThemeModeIndex == 0
      ? ThemeMode.system
      : retrieveSavedThemeModeIndex == 1
          ? ThemeMode.light
          : ThemeMode.dark;
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
  webArchiveDir = (await getApplicationSupportDirectory()).path;

  if (Platform.isIOS) {
    tabViewerBottomOffset1 = 130.0;
    tabViewerBottomOffset2 = 140.0;
    tabViewerBottomOffset3 = 150.0;
  } else {
    tabViewerBottomOffset1 = 110.0;
    tabViewerBottomOffset2 = 120.0;
    tabViewerBottomOffset3 = 130.0;
  }

  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );
    FlutterDownloader.registerCallback(TestClass.callback);
  } else if (Platform.isWindows) {}

  // ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    // ↓↓↓↓↓↓↓↓↓↓↓↓ For the full VTOP browser feature ↓↓↓↓↓↓↓↓↓↓↓↓
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel!.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(WebViewModel()),
        ),
      ],
      // ↑↑↑↑↑↑↑↑↑↑↑↑ For the full VTOP browser feature ↑↑↑↑↑↑↑↑↑↑↑↑
      child: MyApp(
        savedThemeMode: savedThemeMode,
      ),
    ),
  );
  // app initialization is completed so removing the splash screen
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  final ThemeMode? savedThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode? themeMode = widget.savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        title: 'Mini VTOP',
        themeMode: themeMode,
        theme: AppThemeData.lightThemeData.copyWith(),
        darkTheme: AppThemeData.darkThemeData.copyWith(),
        debugShowCheckedModeBanner: false,
        home: Home(
          themeMode: themeMode,
          onThemeMode: (ThemeMode value) {
            setState(() {
              themeMode = value;
              saveThemeMode(value == ThemeMode.system
                  ? 0
                  : value == ThemeMode.light
                      ? 1
                      : 2);
            });
          },
        ),
        routes: {
          PageRoutes.studentProfileAllView: (context) => StudentProfileAllView(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as StudentProfileAllViewArguments,
              ),
          PageRoutes.timeTable: (context) => TimeTable(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as TimeTableArguments,
              ),
          PageRoutes.settings: (context) => Settings(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as SettingsArguments,
              ),
          PageRoutes.classAttendance: (context) => ClassAttendance(
                arguments: ModalRoute.of(context)!.settings.arguments
                    as ClassAttendanceArguments,
              ),
        },
      ),
    );
  }
}

class Home extends StatefulWidget with PreferredSizeWidget {
  const Home({
    Key? key,
    this.themeMode,
    this.onThemeMode,
  }) : super(key: key);

  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeMode;

  @override
  _HomeState createState() => _HomeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool? darkModeOn; // Used to store and get if dark mode is enabled or not.
  late ThemeMode? themeMode = widget
      .themeMode; // Used to store and get which type of theme is currently enabled.

  @override
  void didChangePlatformBrightness() {
    var brightness = WidgetsBinding.instance!.window.platformBrightness;
    debugPrint(
        "brightness.name: ${brightness.name}"); // should print light / dark when we switch
    //updating the status of dartModeOn on detecting change in platform brightness
    setState(() {
      darkModeOn = (themeMode == ThemeMode.dark) ||
          (brightness == Brightness.dark && themeMode == ThemeMode.system);
    });
    super.didChangePlatformBrightness();
  }

  InAppWebViewController? webViewController;

  HeadlessInAppWebView? headlessWebView;
  String currentFullUrl = ""; // Used to store and get the exact url of WebView.

  Image? image; // Used to store and get the latest Captcha.

  String userEnteredUname = ""; // Used to store and get user entered Username.
  String userEnteredPasswd = ""; // Used to store and get user entered Password.
  String autoCaptcha =
      ''; // Used to store and get the automatically solved captcha

  String?
      loggedUserStatus; // Used to store and get the exact location of user in website after logging in

  String? currentStatus =
      "launchLoadingScreen"; // Used to store and get the exact location of user.
  // Mainly used to change main scaffold body.

  bool processingSomething =
      false; // Used to store and get the status of Dialog box.
  // processingSomething = false means no dialog box is open on screen.

  bool refreshingCaptcha =
      true; // Used to store and get the status of captcha loading on refreshing.

  DateTime?
      sessionDateTime; // Used to store and get the date and time at which the user logged in.

  String vtopConnectionStatusType =
      "Initiated"; // Used to store and get the status of website connection.
  // vtopConnectionStatusType == "Initiated" used to show the first trying to load screen.
  // vtopConnectionStatusType == "Connecting" used to show the taking longer than usual loading screen.
  // vtopConnectionStatusType == "Connected" used to show the connected screen.
  // vtopConnectionStatusType == "Error" used to show the taking error screen.

  String vtopConnectionStatusErrorType =
      "None"; // Used to store and get the website connection error type.
  // vtopConnectionStatusErrorType == "None" used to show no connection error.
  // vtopConnectionStatusErrorType == "net::ERR_CONNECTION_TIMED_OUT" used to connection timeout error.
  // vtopConnectionStatusErrorType == "net::ERR_NAME_NOT_RESOLVED" used to show the website cannot be resolved error.
  // vtopConnectionStatusErrorType == "net::ERR_INTERNET_DISCONNECTED" used to show the internet connection is not available error.

  String vtopLoginErrorType =
      "None"; // Used to store and get the website login error type.
  // vtopLoginErrorType == "User Id Not available" used to show error if user entered user id is wrong.
  // vtopLoginErrorType == "Most probably invalid password" used to show error if user entered password is wrong.
  // vtopLoginErrorType == "Invalid Captcha" used to show error if user entered captcha is wrong.
  // vtopLoginErrorType == "Session expired due to inactivity" used to show error if session is expired.
  // vtopLoginErrorType == "Something is wrong! Please retry." used to show error cause of error is unknown.

  late double
      screenBasedPixelWidth; // Used to store and get the (device screen width * 0.0027625) value.

  late double
      screenBasedPixelHeight; // Used to store and get the (device screen height * 0.00169) value.

  late Widget body; // Used to store and get the body of main scaffold.

  late Widget appbar; // Used to store and get the appbar of main scaffold.

  late Widget? drawer; // Used to store and get the drawer of main scaffold.

  int noOfHomePageBuilds =
      0; // Used to store and get the no Of times homepage successfully builds.
  // noOfHomePageBuilds == 0 means homepage didn't build so wait.
  // noOfHomePageBuilds == 1 don't wait as homepage successfully built and ignore further homepage builds.
  // It may also have a use for avoiding declaring again"session expiry avoiding" function variables.

  int noOfLoginAjaxRequests =
      0; // Used to store and get the no of times Login Ajax Requests are made.

  String requestType =
      "Empty"; // Used to store and get the type of action to be taken by an ajax request being made.
  // requestType == "New login" used in studentsRecord/StudentProfileAllView to get the user name and update user status to student portal instantly as user have already successfully logged in.
  // requestType == "Logged in" used in studentsRecord/StudentProfileAllView to get the user name and update user status to student portal but with 2480 milliseconds delay as it will show loading screen successful animation.
  // requestType == "Fake" used in studentsRecord/StudentProfileAllView to check if user session is active or not and if ajaxRequest.status == 200 then just update document and pop any dialog open if timed out then just call inActivityResponse().
  // requestType == "Real" used in studentsRecord/StudentProfileAllView to get all user detail document and then open user detail display scaffold.
  // requestType == "Real" used in academics/common/StudentTimeTable to get user default semester id timetable document and then open user timetable detail display scaffold.
  // requestType == "Update" used in academics/common/StudentTimeTable to get user dropdown selection semester id timetable document and then update timetable detail display scaffold by replacing it with a new one.

  String? studentName; // Used to store and get logged in user name.

  bool credentialsFound =
      false; // Used to check if successfully logged in user credentials are present or not.

  dom.Document?
      studentPortalDocument; // Used to store and get website homepage html document.

  dom.Document?
      studentProfileAllViewDocument; // Used to store and get website studentsRecord/StudentProfileAllView ajax request html document which holds all student related detail.

  dom.Document?
      timeTableDocument; // Used to store and get website processViewTimeTable ajax request html document which holds current selected semester id timetable and subject detail.

  dom.Document?
      classAttendanceDocument; // Used to store and get website processViewStudentAttendance ajax request html document which holds current selected semester id class attendance detail.

  bool tryAutoLoginStatus =
      false; // Used to store and get the status if a user wants to AutoLogin enabled or not.

  String semesterSubIdForTimeTable =
      "BL20212211"; // Used to store and get the user semester sub id for TimeTable.

  String semesterSubIdForAttendance =
      "BL20212211"; // Used to store and get the user semester sub id for Attendance.

  String vtopMode = "Mini VTOP"; // Used to store and get the user vtop mode.

  bool isDialogShowing = false; // Used to store and get the dialog box status.

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // A void function used for calling chooseCorrectBody() function.
  void chooseHomePageBody() {
    // A void function which uses a callback to assign body variable different bodies depending on currentStatus variable value.
    chooseCorrectBody(
      onBody: (Widget value) {
        body = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      tryAutoLoginStatus: tryAutoLoginStatus,
      sessionDateTime: sessionDateTime,
      autoCaptcha: autoCaptcha,
      credentialsFound: credentialsFound,
      studentProfileAllViewDocument: studentProfileAllViewDocument,
      studentPortalDocument: studentPortalDocument,
      vtopLoginErrorType: vtopLoginErrorType,
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          // vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          setState(() {
            refreshingCaptcha = value;
          });
        });
      },
      currentFullUrl: currentFullUrl,
      vtopConnectionStatusType: vtopConnectionStatusType,
      vtopConnectionStatusErrorType: vtopConnectionStatusErrorType,
      onVtopLoginErrorType: (String value) {
        setState(() {
          vtopLoginErrorType = value;
        });
      },
      onRequestType: (String value) {
        setState(() {
          requestType = "Real";
        });
      },
      studentName: studentName,
      onClearUnamePasswd: (bool value) {
        _clearUnamePasswd();
      },
      onRetryOnError: (bool value) {
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        setState(() {
          vtopConnectionStatusErrorType = "None";
          vtopConnectionStatusType = "Initiated";
          debugPrint(
              "restarting headlessInAppWebView manually as vtopConnectionStatusType has error");
          runHeadlessInAppWebView(
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              currentFullUrl = value;
            },
          );
        });
      },
      onTryAutoLoginStatus: (bool value) {
        setState(() {
          tryAutoLoginStatus = value;
          _saveTryAutoLoginStatus();
        });
      },
      themeMode: widget.themeMode,
      onThemeMode: (ThemeMode value) {
        widget.onThemeMode?.call(value);
      },
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
    );
  }

  // A void function used for calling chooseCorrectAppbar() function.
  void chooseHomePageAppbar() {
    // A void function which uses a callback to assign appbar variable different appbars depending on currentStatus variable value.
    chooseCorrectAppbar(
      onAppbar: (Widget value) {
        appbar = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          // vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          refreshingCaptcha = value;
        });
      },
      currentFullUrl: currentFullUrl,
      onCurrentStatus: (String value) {
        setState(() {
          currentStatus = value;
        });
      },
      scaffoldKey: _scaffoldKey,
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          processingSomething = false;
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
    );
  }

  // A void function used for calling chooseCorrectDrawer() function.
  void chooseHomePageDrawer() {
    // A void function which uses a callback to assign drawer variable different drawers depending on currentStatus variable value.
    chooseCorrectDrawer(
      onDrawer: (Widget? value) {
        drawer = value;
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      userEnteredPasswd: userEnteredPasswd,
      userEnteredUname: userEnteredUname,
      headlessWebView: headlessWebView,
      image: image,
      currentStatus: currentStatus,
      loggedUserStatus: loggedUserStatus,
      onUserEnteredPasswd: (String value) {
        setState(() {
          userEnteredPasswd = value;
        });
      },
      context: context,
      onUserEnteredUname: (String value) {
        setState(() {
          userEnteredUname = value;
        });
      },
      onCurrentFullUrl: (String value) {
        setState(() {
          currentFullUrl = value;
        });
      },
      processingSomething: processingSomething,
      onProcessingSomething: (bool value) {
        setState(() {
          processingSomething = value;
          // vtopLoginErrorType = "None";
        });
      },
      refreshingCaptcha: refreshingCaptcha,
      onRefreshingCaptcha: (bool value) {
        setState(() {
          refreshingCaptcha = value;
        });
      },
      currentFullUrl: currentFullUrl,
      onCurrentStatus: (String value) {
        setState(() {
          currentStatus = value;
        });
      },
      themeMode: widget.themeMode,
      onThemeMode: (ThemeMode value) {
        widget.onThemeMode?.call(value);
      },
      onRequestType: (String value) {
        setState(() {
          requestType = value;
        });
      },
      onTryAutoLoginStatus: (bool value) {
        _clearTryAutoLoginStatus();
        setState(() {
          tryAutoLoginStatus = value;
          _saveTryAutoLoginStatus();
        });
      },
      onError: (String value) {
        debugPrint("Updating Ui based on the error received");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          processingSomething = false;
        }
        if (value == "net::ERR_INTERNET_DISCONNECTED") {
          debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
            vtopConnectionStatusType = "Error";
          });
        }
      },
      timeTableDocument: timeTableDocument,
      semesterSubIdForTimeTable: semesterSubIdForTimeTable,
      onUpdateDefaultTimeTableSemesterId: (String value) {
        setState(() {
          semesterSubIdForTimeTable = value;
        });
        _saveSemesterSubIdForTimeTable();
      },
      onUpdateVtopMode: (String value) {
        setState(() {
          if (value == "Mini VTOP") {
            currentStatus = "userLoggedIn";
            vtopMode = "Mini VTOP";
          } else if (value == "Full VTOP") {
            currentStatus = "originalVTOP";
            vtopMode = "Full VTOP";
          }
        });
      },
      onUpdateDefaultVtopMode: (String value) {
        setState(() {
          vtopMode = value;
        });
        _saveVtopMode();
      },
      vtopMode: vtopMode,
      onLoggedUserStatus: (String value) {
        setState(() {
          loggedUserStatus = value;
        });
      },
      classAttendanceDocument: classAttendanceDocument,
      semesterSubIdForAttendance: semesterSubIdForAttendance,
      onUpdateDefaultAttendanceSemesterId: (String value) {
        setState(() {
          semesterSubIdForAttendance = value;
        });
        _saveSemesterSubIdForAttendance();
      },
    );
  }

  bool?
      usingVITWifi; // Used to store and get if the user is using VIT wifi or not.

  late List<Widget> dialogActionButtonsListForGettingWifiType = [
    CustomTextButton(
      onPressed: () {
        usingVITWifi = false;
        Navigator.of(context).pop();
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      size: const Size(20, 50),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        'NO',
      ),
    ),
    CustomTextButton(
      onPressed: () {
        usingVITWifi = true;
        Navigator.of(context).pop();
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      size: const Size(20, 50),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        'YES',
      ),
    ),
  ];

  getWifiTypeDialogBox() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        processingSomething = true;
      }); //then set processing something true for the new loading dialog
      customAlertDialogBox(
        isDialogShowing: isDialogShowing,
        context: context,
        onIsDialogShowing: (bool value) {
          setState(() {
            isDialogShowing = value;
          });
        },
        dialogTitle: 'Heads Up!',
        dialogContent: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you connected to VIT Bhopal Wifi?',
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
          setState(() {
            processingSomething = value;
          });
        },
        dialogActions: dialogActionButtonsListForGettingWifiType,
      ).then((_) {
        if (usingVITWifi == true) {
          runDnsSettingsDialogBox();
        }
        processingSomething = false;
        return isDialogShowing = false;
      });
    });
  }

  late List<Widget> dialogActionButtonsListForDnsSettings = [
    CustomTextButton(
      onPressed: () {
        Navigator.of(context).pop();
        OpenSettings.openAirplaneModeSetting();
      },
      screenBasedPixelWidth: screenBasedPixelWidth,
      screenBasedPixelHeight: screenBasedPixelHeight,
      size: const Size(20, 50),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        'OPEN SETTINGS',
      ),
    ),
  ];

  runDnsSettingsDialogBox() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        processingSomething = true;
      }); //then set processing something true for the new loading dialog
      customAlertDialogBox(
        isDialogShowing: isDialogShowing,
        context: context,
        onIsDialogShowing: (bool value) {
          setState(() {
            isDialogShowing = value;
          });
        },
        dialogTitle: 'Please Read!',
        dialogContent: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'If you are connected to VIT Bhopal wifi then there could be two reasons for getting this error:-\n\n1. Official VTOP is down right now.\n2. Your DNS setting is turned on.\n\n To verify if its the 2nd reason try accessing the app using mobile data and if you connect successfully then its the 2nd reason above. If its the 2nd reason then turn off the DNS from network settings and try again.',
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
          setState(() {
            processingSomething = value;
          });
        },
        dialogActions: dialogActionButtonsListForDnsSettings,
      ).then((_) {
        processingSomething = false;
        return isDialogShowing = false;
      });
    });
  }

  openStudentProfileAllView({required String forXAction}) async {
    await headlessWebView?.webViewController.evaluateJavascript(source: '''
                               document.getElementById("STA002").click();
                                ''');
    requestType = forXAction;
  }

  Future<void> _credentialsFound() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userEnteredPasswd') &&
        !prefs.containsKey('userEnteredUname')) {
      credentialsFound = false;
      return;
    }
    setState(() {
      credentialsFound = true;
    });
  }

  Future<void> _retrieveUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('userEnteredPasswd') &&
        !prefs.containsKey('userEnteredUname')) {
      return;
    }

    setState(() {
      userEnteredUname = prefs.getString('userEnteredUname')!;
      userEnteredPasswd = prefs.getString('userEnteredPasswd')!;
    });
  }

  Future<void> _retrieveSessionDateTime() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('sessionDateTime')) {
      return;
    }

    setState(() {
      sessionDateTime = DateTime.parse(prefs.getString('sessionDateTime')!);
    });
  }

  Future<void> _retrieveTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('tryAutoLoginStatus')) {
      return;
    }

    setState(() {
      tryAutoLoginStatus = prefs.getBool('tryAutoLoginStatus')!;
    });
  }

  Future<void> _retrieveSemesterSubIdForAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubIdForAttendance')) {
      return;
    }

    setState(() {
      semesterSubIdForAttendance =
          prefs.getString('semesterSubIdForAttendance')!;
    });
  }

  Future<String> _justRetrieveSemesterSubIdForAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubIdForAttendance')) {
      semesterSubIdForAttendance = "BL20212211";
      return "BL20212211";
    }

    semesterSubIdForAttendance = prefs.getString('semesterSubIdForAttendance')!;
    return prefs.getString('semesterSubIdForAttendance')!;
  }

  Future<void> _retrieveSemesterSubIdForTimeTable() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubIdForTimeTable')) {
      return;
    }

    setState(() {
      semesterSubIdForTimeTable = prefs.getString('semesterSubIdForTimeTable')!;
    });
  }

  Future<String> _justRetrieveSemesterSubIdForTimeTable() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('semesterSubIdForTimeTable')) {
      semesterSubIdForTimeTable = "BL20212211";
      return "BL20212211";
    }

    semesterSubIdForTimeTable = prefs.getString('semesterSubIdForTimeTable')!;
    return prefs.getString('semesterSubIdForTimeTable')!;
  }

  Future<String> _justRetrieveVtopMode() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('vtopMode')) {
      vtopMode = "Mini VTOP";
      return "Mini VTOP";
    }

    vtopMode = prefs.getString('vtopMode')!;
    return prefs.getString('vtopMode')!;
  }

  Future<void> _saveSessionDateTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionDateTime', sessionDateTime.toString());
  }

  Future<void> _saveSemesterSubIdForAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'semesterSubIdForAttendance', semesterSubIdForAttendance.toString());
  }

  Future<void> _saveSemesterSubIdForTimeTable() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'semesterSubIdForTimeTable', semesterSubIdForTimeTable.toString());
  }

  Future<void> _saveVtopMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('vtopMode', vtopMode.toString());
  }

  Future<void> _saveTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('tryAutoLoginStatus', tryAutoLoginStatus);
  }

  Future<void> _saveUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userEnteredUname', userEnteredUname);
    prefs.setString('userEnteredPasswd', userEnteredPasswd);
  }

  Future<void> _clearUnamePasswd() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the name is saved before or not
    if (!prefs.containsKey('userEnteredUname') &&
        !prefs.containsKey('userEnteredPasswd')) {
      return;
    }

    await prefs.remove('userEnteredUname');
    await prefs.remove('userEnteredPasswd');
    setState(() {
      userEnteredUname = '';
      userEnteredPasswd = "";

      credentialsFound = false;
    });
  }

  Future<void> _clearTryAutoLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the name is saved before or not
    if (!prefs.containsKey('tryAutoLoginStatus')) {
      return;
    }

    await prefs.remove('tryAutoLoginStatus');
    setState(() {
      tryAutoLoginStatus = false;
    });
  }

  bool isStopped = false;

  late Timer timer;
  late Brightness brightness;

  void checkInternetConnection() async {
    if (!await InternetConnectionChecker().hasConnection &&
        vtopConnectionStatusType != "Connected") {
      debugPrint(
          "InternetConnectionChecker plugin detected no internet access");
      setState(() {
        currentStatus = "launchLoadingScreen";
        vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
        vtopConnectionStatusType = "Error";
      });
    }
  }

  @override
  void didChangeDependencies() {
    screenBasedPixelWidth = MediaQuery.of(context).size.width * 0.0027625;
    screenBasedPixelHeight = MediaQuery.of(context).size.height * 0.00169;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    // Reassigning new values to brightness, darkModeOn on every oldWidget.themeMode != widget.themeMode
    // so that they get accurate values if parent widgets update these value
    if (oldWidget.themeMode != widget.themeMode) {
      brightness = WidgetsBinding.instance!.window.platformBrightness;
      darkModeOn = (widget.themeMode == ThemeMode.system &&
              brightness == Brightness.dark) ||
          widget.themeMode == ThemeMode.dark;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    headlessWebView?.dispose();
  }

  @override
  void initState() {
    inActivityOrStatusNot200Response(
        {required String dialogTitle, required String dialogChildrenText}) {
      debugPrint("You are logged out as $dialogTitle");
      debugPrint("called inActivityOrStatusNot200Response for ajaxRequests");

      if (processingSomething == true) {
        Navigator.of(context).pop();
        setState(() {
          processingSomething = false;
        });
      }
      if (loggedUserStatus != "studentPortalScreen" &&
          loggedUserStatus != null) {
        debugPrint("closing open gages on auto logout on session time end");
        Navigator.of(context).pop();
      }

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        processingSomething = true;
        customAlertDialogBox(
          isDialogShowing: isDialogShowing,
          context: context,
          onIsDialogShowing: (bool value) {
            setState(() {
              isDialogShowing = value;
            });
          },
          dialogTitle: dialogTitle,
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
                      fixedSize: 4,
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
              ),
              Text(
                dialogChildrenText,
                style: TextStyle(
                  fontSize: widgetSizeProvider(
                      fixedSize: 20,
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          barrierDismissible: false,
          screenBasedPixelHeight: screenBasedPixelHeight,
          screenBasedPixelWidth: screenBasedPixelWidth,
          onProcessingSomething: (bool value) {
            setState(() {
              processingSomething = value;
            });
          },
        ).then((_) {
          processingSomething = false;
          return isDialogShowing = false;
        });
      });

      performSignOut(
        context: context,
        headlessWebView: headlessWebView,
        onCurrentFullUrl: (String value) {
          setState(() {
            currentFullUrl = value;
          });
        },
        onError: (String value) {
          debugPrint("Updating Ui based on the error received");
          if (processingSomething == true) {
            Navigator.of(context).pop();
            setState(() {
              processingSomething = false;
            });
          }
          if (value == "net::ERR_INTERNET_DISCONNECTED") {
            debugPrint("Updating Ui for net::ERR_INTERNET_DISCONNECTED");
            setState(() {
              currentStatus = "launchLoadingScreen";
              vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
              vtopConnectionStatusType = "Error";
            });
          }
        },
      );

      setState(() {
        currentStatus = "launchLoadingScreen";
      });
    }

    super.initState();
    WidgetsBinding.instance!.addObserver(this); //most important
    var brightness = WidgetsBinding.instance!.window.platformBrightness;
    debugPrint(
        "brightness.name: ${brightness.name}"); // should print light / dark when we switch
    //updating the status of dartModeOn on detecting change in platform brightness
    setState(() {
      darkModeOn = (themeMode == ThemeMode.dark) ||
          (brightness == Brightness.dark && themeMode == ThemeMode.system);
    });

    _retrieveUnamePasswd();
    _credentialsFound();
    _retrieveSessionDateTime();
    _retrieveTryAutoLoginStatus();
    _retrieveSemesterSubIdForAttendance();
    _retrieveSemesterSubIdForTimeTable();
    _justRetrieveVtopMode();

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
          // url: Uri.parse("")),
          url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
      initialOptions: options,
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        if (kDebugMode) {
          print(challenge);
        }
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null &&
            (sslError.iosError != null || sslError.androidError != null)) {
          if (Platform.isIOS && sslError.iosError == IOSSslError.UNSPECIFIED) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onDownloadStart: (controller, url) async {
        String path = url.path;
        String fileName = path.substring(path.lastIndexOf('/') + 1);
        if (Platform.isAndroid) {
          final taskId = await FlutterDownloader.enqueue(
            url: url.toString(),
            fileName: fileName,
            savedDir: (await getTemporaryDirectory()).path,
            showNotification: true,
            openFileFromNotification: true,
            saveInPublicStorage: true,
          );
          debugPrint(taskId.toString());
        } else if (Platform.isWindows) {}
      },
      onWebViewCreated: (controller) async {
        checkInternetConnection();
        Future.delayed(const Duration(seconds: 5), () async {
          if (vtopConnectionStatusType == "Initiated") {
            if (mounted) {
              setState(() {
                vtopConnectionStatusType = "Connecting";
              });
            }
          }
        });

        timer = Timer.periodic(const Duration(seconds: 20), (Timer t) {
          if (currentStatus == "launchLoadingScreen" &&
              vtopConnectionStatusErrorType == "None") {
            debugPrint(
                "restarting headlessInAppWebView as webview is taking too long");

            runHeadlessInAppWebView(
              headlessWebView: headlessWebView,
              onCurrentFullUrl: (String value) {
                currentFullUrl = value;
              },
            );
          }
        });
      },
      androidShouldInterceptRequest: (controller, webResourceRequest) async {
        debugPrint('Console Message: $webResourceRequest');
        return null;
      },
      onConsoleMessage: (controller, consoleMessage) {
        if (kDebugMode) {
          print('Console Message: ${consoleMessage.message}');
        }

        if (consoleMessage.message.contains("solvedCaptcha:")) {
          setState(() {
            autoCaptcha = consoleMessage.message.split(' ').sublist(1)[0];
          });
        }
      },
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return ajaxRequest;
      },
      onAjaxReadyStateChange:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return AjaxRequestAction.PROCEED;
      },
      onAjaxProgress:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        if (ajaxRequest.event?.type == AjaxRequestEventType.LOADEND) {
          if (ajaxRequest.url.toString() == "vtopLogin") {
            // printWrapped("ajaxRequest: ${ajaxRequest}");
            noOfLoginAjaxRequests++;

            debugPrint("noOfHomePageBuilds: ${noOfHomePageBuilds.toString()}");
            debugPrint(
                "noOfLoginAjaxRequests: ${noOfLoginAjaxRequests.toString()}");
            debugPrint(
                "vtopLogin ajaxRequest.status: ${ajaxRequest.status.toString()}");

            if (ajaxRequest.status == 200) {
              var document = parse('${ajaxRequest.responseText}');
              String? imageSrc = document
                  .querySelector('img[alt="vtopCaptcha"]')
                  ?.attributes["src"];
              // print(imageSrc!);
              String uri = imageSrc!;
              String base64String = uri.split(', ').last;
              Uint8List _bytes = base64.decode(base64String);

              autoFillCaptcha(
                  context: context,
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  });

              setState(() {
                vtopConnectionStatusType = "Connected";
              });

              Future.delayed(const Duration(milliseconds: 2480), () async {
                setState(() {
                  image = Image.memory(_bytes);
                  currentStatus = "signInScreen";
                  processingSomething = false;
                  refreshingCaptcha = false;
                });
              });
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Session ended',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            } else if (ajaxRequest.status != 200) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Request Status != 200',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            }
          } else if (ajaxRequest.url.toString() == "doLogin") {
            // print("ajaxRequest: ${ajaxRequest}");
            await controller
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              if (ajaxRequest.status == 200) {
                if (value.contains(userEnteredUname + "(STUDENT)")) {
                  printWrapped("User $userEnteredUname successfully signed in");

                  _saveUnamePasswd();
                  sessionDateTime = await NTP.now().then((value) {
                    _saveSessionDateTime();
                    debugPrint(
                        'NTP DateTime: $sessionDateTime, DateTime: ${DateTime.now().toString()}');

                    manageUserSession(
                      context: context,
                      headlessWebView: headlessWebView,
                      onCurrentFullUrl: (String value) {
                        setState(() {
                          currentFullUrl = value;
                        });
                      },
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                      onRequestType: (String value) {
                        setState(() {
                          requestType = value;
                        });
                      },
                      onError: (String value) {
                        debugPrint("Updating Ui based on the error received");
                        if (processingSomething == true) {
                          Navigator.of(context).pop();
                          processingSomething = false;
                        }
                        if (value == "net::ERR_INTERNET_DISCONNECTED") {
                          debugPrint(
                              "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                          setState(() {
                            currentStatus = "launchLoadingScreen";
                            vtopConnectionStatusErrorType =
                                "net::ERR_INTERNET_DISCONNECTED";
                            vtopConnectionStatusType = "Error";
                          });
                        }
                      },
                    );
                    openStudentProfileAllView(forXAction: 'New login');
                    // Actually we are using openStudentProfileAllView() to get profile document
                    // and then setting the currentStatus = "userLoggedIn" in the studentsRecord/StudentProfileAllView ajax request.

                    setState(() {
                      studentPortalDocument =
                          parse('${ajaxRequest.responseText}');
                    });
                    return value;
                  });
                } else if (value.contains("User Id Not available")) {
                  printWrapped("User Id Not available");
                  // User Id Not available WHEN ENTERING WRONG USER ID
                  // processingSomething = false;
                  // We commented the statement because we put this inside the onloadstop.
                  // We know that processing is already validated but we still want to show the dialog until user sees the updated login page
                  vtopLoginErrorType = "User Id Not available";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else if (value.contains("Invalid User Id / Password")) {
                  printWrapped("Most probably invalid password");
                  //Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
                  vtopLoginErrorType = "Most probably invalid password";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else if (value.contains("Invalid Captcha")) {
                  printWrapped("Invalid Captcha");
                  //Invalid Captcha WHEN ENTERING WRONG CAPTCHA
                  vtopLoginErrorType = "Invalid Captcha";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else if (value.contains(
                        "You are logged out due to inactivity for more than 15 minutes") ||
                    ajaxRequest.responseText!
                        .contains("You have been successfully logged out")) {
                  printWrapped(
                      "Most probably session expired due to inactivity");
                  //Invalid User Id / Password WHEN ENTERING CORRECT ID BUT WRONG PASSWORD
                  vtopLoginErrorType = "Session expired due to inactivity";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                } else {
                  printWrapped(
                      "Can't find why something got wrong enable print ajaxRequest for doLogin and see the logs");
                  printWrapped("ajaxRequest: $ajaxRequest");
                  vtopLoginErrorType = "Something is wrong! Please retry.";
                  runHeadlessInAppWebView(
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                  );
                }
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Session ended',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              } else if (ajaxRequest.status != 200) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Request Status != 200',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              }
            });
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            // printWrapped("ajaxRequest: ${ajaxRequest}");

            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.status == 200) {
                if (ajaxRequest.responseText!.contains(
                        "You are logged out due to inactivity for more than 15 minutes") ||
                    ajaxRequest.responseText!
                        .contains("You have been successfully logged out")) {
                  inActivityOrStatusNot200Response(
                      dialogTitle: 'Session ended',
                      dialogChildrenText:
                          'Starting new session\nplease wait...');
                } else {
                  var document = parse('${ajaxRequest.responseText}');
                  String? imageSrc = document
                      .querySelector('img[alt="vtopCaptcha"]')
                      ?.attributes["src"];
                  String uri = imageSrc!;
                  String base64String = uri.split(', ').last;
                  Uint8List _bytes = base64.decode(base64String);
                  // printWrapped("vtopCaptcha _bytes: $base64String");

                  autoFillCaptcha(
                      context: context,
                      headlessWebView: headlessWebView,
                      onCurrentFullUrl: (String value) {
                        setState(() {
                          currentFullUrl = value;
                        });
                      });

                  setState(() {
                    refreshingCaptcha = false;
                    image = Image.memory(_bytes);
                  });
                }
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Session ended',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              } else if (ajaxRequest.status != 200) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Request Status != 200',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              }
            }
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            // printWrapped("ajaxRequest: ${ajaxRequest}");

            if (requestType == "New login") {
              _credentialsFound();
              setState(() {
                vtopConnectionStatusType = "Connected";
              });

              await headlessWebView?.webViewController
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) {
                var document = parse('$value');

                setState(() {
                  studentProfileAllViewDocument = document;
                  studentName = studentProfileAllViewDocument
                      ?.getElementById('exTab1')
                      ?.children[1]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[0]
                      .children[2]
                      .children[1]
                      .innerHtml;
                  if (vtopMode == "Mini VTOP") {
                    currentStatus = "userLoggedIn";
                  } else if (vtopMode == "Full VTOP") {
                    currentStatus = "originalVTOP";
                  }
                  loggedUserStatus = "studentPortalScreen";
                  Navigator.of(context)
                      .pop(); //used to pop the dialog of signIn processing as it will not pop automatically as currentStatus will not be "runHeadlessInAppWebView" and loginpage will not open with the logic to pop it.
                  processingSomething = false;
                });
              });
            } else if (requestType == "Logged in") {
              _credentialsFound();
              manageUserSession(
                context: context,
                headlessWebView: headlessWebView,
                onCurrentFullUrl: (String value) {
                  setState(() {
                    currentFullUrl = value;
                  });
                },
                onProcessingSomething: (bool value) {
                  setState(() {
                    processingSomething = value;
                  });
                },
                onRequestType: (String value) {
                  setState(() {
                    requestType = value;
                  });
                },
                onError: (String value) {
                  debugPrint("Updating Ui based on the error received");
                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    processingSomething = false;
                  }
                  if (value == "net::ERR_INTERNET_DISCONNECTED") {
                    debugPrint(
                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                    setState(() {
                      currentStatus = "launchLoadingScreen";
                      vtopConnectionStatusErrorType =
                          "net::ERR_INTERNET_DISCONNECTED";
                      vtopConnectionStatusType = "Error";
                    });
                  }
                },
              );
              setState(() {
                vtopConnectionStatusType = "Connected";
              });

              Future.delayed(const Duration(milliseconds: 2480), () async {
                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) {
                  var document = parse('$value');
                  setState(() {
                    studentProfileAllViewDocument = document;
                    studentName = studentProfileAllViewDocument
                        ?.getElementById('exTab1')
                        ?.children[1]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[0]
                        .children[2]
                        .children[1]
                        .innerHtml;

                    if (vtopMode == "Mini VTOP") {
                      currentStatus = "userLoggedIn";
                    } else if (vtopMode == "Full VTOP") {
                      currentStatus = "originalVTOP";
                    }

                    loggedUserStatus = "studentPortalScreen";
                  });
                });
              });
            } else if (requestType == "Fake") {
              debugPrint(
                  "Fake request executed by calling callStudentProfileAllView() with onRequestType as Fake");
              if (ajaxRequest.status == 200) {
                requestType = "Empty";

                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) {
                  var document = parse('$value');
                  setState(() {
                    studentProfileAllViewDocument = document;
                  });

                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }
                });
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Session ended',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              } else if (ajaxRequest.status != 200) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Request Status != 200',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              }
            } else if (requestType == "Real") {
              if (ajaxRequest.status == 200) {
                requestType = "Empty";

                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) {
                  var document = parse('$value');
                  setState(() {
                    studentProfileAllViewDocument = document;
                  });

                  if (processingSomething == true) {
                    Navigator.of(context).pop();
                    setState(() {
                      processingSomething = false;
                    });
                  }

                  Navigator.pushNamed(
                    context,
                    PageRoutes.studentProfileAllView,
                    arguments: StudentProfileAllViewArguments(
                      currentStatus: currentStatus,
                      onWidgetDispose: (bool value) {
                        debugPrint("studentProfileAllView disposed");
                        WidgetsBinding.instance
                            ?.addPostFrameCallback((_) => setState(() {
                                  loggedUserStatus = "studentPortalScreen";
                                }));
                      },
                      studentProfileAllViewDocument:
                          studentProfileAllViewDocument,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      screenBasedPixelHeight: screenBasedPixelHeight,
                    ),
                  );
                  setState(() {
                    loggedUserStatus = "studentProfileAllView";
                  });
                });
              } else if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Session ended',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              } else if (ajaxRequest.status != 200) {
                inActivityOrStatusNot200Response(
                    dialogTitle: 'Request Status != 200',
                    dialogChildrenText: 'Starting new session\nplease wait...');
              }
            }
          } else if (ajaxRequest.url.toString() == "processLogout") {
            // print("ajaxRequest: ${ajaxRequest}");

            debugPrint("processing logout");
            if (processingSomething == true) {
              Navigator.of(context).pop();
              setState(() {
                processingSomething = false;
              });
            }
            if (loggedUserStatus != "studentPortalScreen" &&
                loggedUserStatus != null) {
              debugPrint(
                  "closing open gages on auto logout on session time end");
              Navigator.of(context).pop();
            }

            if (ajaxRequest.responseText != null) {
              if (ajaxRequest.responseText!.contains(
                      "You are logged out due to inactivity for more than 15 minutes") ||
                  ajaxRequest.responseText!
                      .contains("You have been successfully logged out")) {
                setState(() {
                  currentStatus = "launchLoadingScreen";
                  vtopConnectionStatusType = "Initiated";
                });

                debugPrint(
                    "called inactivityResponse or successfullyLogout Action https://vtop.vitbhopal.ac.in/vtop for processLogout");
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    currentFullUrl = value;
                  },
                );
              }
            }
          } else if (ajaxRequest.url.toString() ==
              "academics/common/StudentTimeTable") {
            // debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              bool waitStatus = true;
              while (waitStatus == true) {
                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) async {
                  if (value.contains("Please wait")) {
                  } else {
                    if (requestType == "Real") {
                      debugPrint(
                          "new semesterSubIdForTimeTable: $semesterSubIdForTimeTable");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForTimeTable()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "Update") {
                      debugPrint(
                          "new semesterSubIdForTimeTable: $semesterSubIdForTimeTable");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "$semesterSubIdForTimeTable";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "Fake") {
                      debugPrint(
                          "new semesterSubIdForTimeTable: $semesterSubIdForTimeTable");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForTimeTable()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "ForDrawer") {
                      debugPrint(
                          "new semesterSubIdForTimeTable: $semesterSubIdForTimeTable");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForTimeTable()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    }
                  }
                });
              }
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Session ended',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            } else if (ajaxRequest.status != 200) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Request Status != 200',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            }
          } else if (ajaxRequest.url.toString() == "processViewTimeTable") {
            // debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              await headlessWebView?.webViewController
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) async {
                var document = parse('$value');
                setState(() {
                  timeTableDocument = document;
                });
                if (processingSomething == true && requestType != "ForDrawer") {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }
                if (requestType == "Real") {
                  DateTime? currentDateTime = await NTP.now();
                  Navigator.pushNamed(
                    context,
                    PageRoutes.timeTable,
                    arguments: TimeTableArguments(
                      currentStatus: currentStatus,
                      currentDateTime: currentDateTime,
                      onWidgetDispose: (bool value) {
                        debugPrint("timeTable disposed");
                        WidgetsBinding.instance
                            ?.addPostFrameCallback((_) => setState(() {
                                  loggedUserStatus = "studentPortalScreen";
                                }));
                      },
                      timeTableDocument: timeTableDocument,
                      screenBasedPixelHeight: screenBasedPixelHeight,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      semesterSubIdForTimeTable:
                          await _justRetrieveSemesterSubIdForTimeTable(),
                      onSemesterSubIdChange: (String value) {
                        setState(() {
                          semesterSubIdForTimeTable = value;
                          requestType = "Update";
                          callTimeTable(
                            context: context,
                            headlessWebView: headlessWebView,
                            onCurrentFullUrl: (String value) {
                              currentFullUrl = value;
                            },
                            processingSomething: true,
                            onProcessingSomething: (bool value) {
                              processingSomething = true;
                            },
                            onError: (String value) {
                              debugPrint(
                                  "Updating Ui based on the error received");
                              if (processingSomething == true) {
                                Navigator.of(context).pop();
                                setState(() {
                                  processingSomething = false;
                                });
                              }
                              if (value == "net::ERR_INTERNET_DISCONNECTED") {
                                debugPrint(
                                    "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                setState(() {
                                  currentStatus = "launchLoadingScreen";
                                  vtopConnectionStatusErrorType =
                                      "net::ERR_INTERNET_DISCONNECTED";
                                  vtopConnectionStatusType = "Error";
                                });
                              }
                            },
                          );
                        });
                      },
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                    ),
                  );
                  setState(() {
                    loggedUserStatus = "timeTable";
                  });
                } else if (requestType == "Update") {
                  debugPrint("Table Update Ran");
                  DateTime? currentDateTime = await NTP.now();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (buildContext, animation1, animation2) =>
                          TimeTable(
                        arguments: TimeTableArguments(
                          currentStatus: currentStatus,
                          currentDateTime: currentDateTime,
                          onWidgetDispose: (bool value) {
                            debugPrint("timeTable disposed");
                            WidgetsBinding.instance
                                ?.addPostFrameCallback((_) => setState(() {
                                      loggedUserStatus = "studentPortalScreen";
                                    }));
                          },
                          timeTableDocument: timeTableDocument,
                          screenBasedPixelHeight: screenBasedPixelHeight,
                          screenBasedPixelWidth: screenBasedPixelWidth,
                          semesterSubIdForTimeTable: semesterSubIdForTimeTable,
                          onSemesterSubIdChange: (String value) {
                            setState(() {
                              semesterSubIdForTimeTable = value;
                              requestType = "Update";
                              callTimeTable(
                                context: context,
                                headlessWebView: headlessWebView,
                                onCurrentFullUrl: (String value) {
                                  currentFullUrl = value;
                                },
                                processingSomething: true,
                                onProcessingSomething: (bool value) {
                                  processingSomething = true;
                                },
                                onError: (String value) {
                                  debugPrint(
                                      "Updating Ui based on the error received");
                                  if (processingSomething == true) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      processingSomething = false;
                                    });
                                  }
                                  if (value ==
                                      "net::ERR_INTERNET_DISCONNECTED") {
                                    debugPrint(
                                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                    setState(() {
                                      currentStatus = "launchLoadingScreen";
                                      vtopConnectionStatusErrorType =
                                          "net::ERR_INTERNET_DISCONNECTED";
                                      vtopConnectionStatusType = "Error";
                                    });
                                  }
                                },
                              );
                            });
                          },
                          onProcessingSomething: (bool value) {
                            setState(() {
                              processingSomething = value;
                            });
                          },
                        ),
                      ),
                      // transitionsBuilder:
                      //     (context, animation, secondaryAnimation, child) =>
                      //         FadeTransition(opacity: animation, child: child),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: Duration.zero,
                      // reverseTransitionDuration:
                      //     // const Duration(milliseconds: 2000),
                    ),
                  );
                  setState(() {
                    loggedUserStatus = "timeTable";
                  });
                } else if (requestType == "Fake") {
                } else if (requestType == "ForDrawer") {
                  debugPrint("Request For Drawer");
                  // semesterSubId = await _justRetrieveSemesterSubId();
                  setState(() {
                    requestType = "ForDrawer";
                  });
                  callClassAttendance(
                    context: context,
                    headlessWebView: headlessWebView,
                    onCurrentFullUrl: (String value) {
                      setState(() {
                        currentFullUrl = value;
                      });
                    },
                    processingSomething: true,
                    onProcessingSomething: (bool value) {
                      setState(() {
                        processingSomething = value;
                      });
                    },
                    onError: (String value) {
                      debugPrint("Updating Ui based on the error received");
                      if (processingSomething == true) {
                        Navigator.of(context).pop();
                        setState(() {
                          processingSomething = false;
                        });
                      }
                      if (value == "net::ERR_INTERNET_DISCONNECTED") {
                        debugPrint(
                            "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                        setState(() {
                          currentStatus = "launchLoadingScreen";
                          vtopConnectionStatusErrorType =
                              "net::ERR_INTERNET_DISCONNECTED";
                          vtopConnectionStatusType = "Error";
                        });
                      }
                    },
                  );
                }
              });
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Session ended',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            } else if (ajaxRequest.status != 200) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Request Status != 200',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            }
          } else if (ajaxRequest.url.toString() ==
              "academics/common/StudentAttendance") {
            // debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              bool waitStatus = true;
              while (waitStatus == true) {
                await headlessWebView?.webViewController
                    .evaluateJavascript(
                        source:
                            "new XMLSerializer().serializeToString(document);")
                    .then((value) async {
                  if (value.contains("Please wait")) {
                    // waitStatus = true;
                  } else {
                    if (requestType == "Real") {
                      debugPrint(
                          "new semesterSubIdForAttendance: $semesterSubIdForAttendance");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForAttendance()}";
             document.querySelectorAll('[type=submit]')[0].click();
          
                                ''');
                    } else if (requestType == "Update") {
                      debugPrint(
                          "new semesterSubIdForAttendance: $semesterSubIdForAttendance");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "$semesterSubIdForAttendance";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "Fake") {
                      debugPrint(
                          "new semesterSubIdForAttendance: $semesterSubIdForAttendance");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForAttendance()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    } else if (requestType == "ForDrawer") {
                      debugPrint(
                          "new semesterSubIdForAttendance: $semesterSubIdForAttendance");
                      waitStatus = false;
                      await headlessWebView?.webViewController
                          .evaluateJavascript(source: '''
             document.getElementById('semesterSubId').value = "${await _justRetrieveSemesterSubIdForAttendance()}";
             document.querySelectorAll('[type=submit]')[0].click();
                                ''');
                    }
                  }
                });
              }
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Session ended',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            } else if (ajaxRequest.status != 200) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Request Status != 200',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            }
          } else if (ajaxRequest.url.toString() ==
              "processViewStudentAttendance") {
            debugPrint("ajaxRequest: $ajaxRequest");

            if (ajaxRequest.status == 200) {
              await headlessWebView?.webViewController
                  .evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);")
                  .then((value) async {
                var document = parse('$value');
                setState(() {
                  classAttendanceDocument = document;
                });
                if (processingSomething == true) {
                  Navigator.of(context).pop();
                  setState(() {
                    processingSomething = false;
                  });
                }
                if (requestType == "Real") {
                  // semesterSubIdForAttendance = await _justRetrieveSemesterSubIdForAttendance();
                  Navigator.pushNamed(
                    context,
                    PageRoutes.classAttendance,
                    arguments: ClassAttendanceArguments(
                      currentStatus: currentStatus,
                      onWidgetDispose: (bool value) {
                        debugPrint("classAttendance disposed");
                        WidgetsBinding.instance
                            ?.addPostFrameCallback((_) => setState(() {
                                  loggedUserStatus = "studentPortalScreen";
                                }));
                      },
                      classAttendanceDocument: classAttendanceDocument,
                      screenBasedPixelHeight: screenBasedPixelHeight,
                      screenBasedPixelWidth: screenBasedPixelWidth,
                      semesterSubIdForAttendance:
                          await _justRetrieveSemesterSubIdForAttendance(),
                      onSemesterSubIdChange: (String value) {
                        setState(() {
                          semesterSubIdForAttendance = value;
                          requestType = "Update";
                          callClassAttendance(
                            context: context,
                            headlessWebView: headlessWebView,
                            onCurrentFullUrl: (String value) {
                              currentFullUrl = value;
                            },
                            processingSomething: true,
                            onProcessingSomething: (bool value) {
                              processingSomething = true;
                            },
                            onError: (String value) {
                              debugPrint(
                                  "Updating Ui based on the error received");
                              if (processingSomething == true) {
                                Navigator.of(context).pop();
                                setState(() {
                                  processingSomething = false;
                                });
                              }
                              if (value == "net::ERR_INTERNET_DISCONNECTED") {
                                debugPrint(
                                    "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                setState(() {
                                  currentStatus = "launchLoadingScreen";
                                  vtopConnectionStatusErrorType =
                                      "net::ERR_INTERNET_DISCONNECTED";
                                  vtopConnectionStatusType = "Error";
                                });
                              }
                            },
                          );
                        });
                      },
                      onProcessingSomething: (bool value) {
                        setState(() {
                          processingSomething = value;
                        });
                      },
                    ),
                  );
                  setState(() {
                    loggedUserStatus = "classAttendance";
                  });
                } else if (requestType == "Update") {
                  debugPrint("Table Update Ran");
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (buildContext, animation1, animation2) =>
                          ClassAttendance(
                        arguments: ClassAttendanceArguments(
                          currentStatus: currentStatus,
                          onWidgetDispose: (bool value) {
                            debugPrint("ClassAttendance disposed");
                            WidgetsBinding.instance
                                ?.addPostFrameCallback((_) => setState(() {
                                      loggedUserStatus = "studentPortalScreen";
                                    }));
                          },
                          classAttendanceDocument: classAttendanceDocument,
                          screenBasedPixelHeight: screenBasedPixelHeight,
                          screenBasedPixelWidth: screenBasedPixelWidth,
                          semesterSubIdForAttendance:
                              semesterSubIdForAttendance,
                          onSemesterSubIdChange: (String value) {
                            setState(() {
                              semesterSubIdForAttendance = value;
                              requestType = "Update";
                              callClassAttendance(
                                context: context,
                                headlessWebView: headlessWebView,
                                onCurrentFullUrl: (String value) {
                                  currentFullUrl = value;
                                },
                                processingSomething: true,
                                onProcessingSomething: (bool value) {
                                  processingSomething = true;
                                },
                                onError: (String value) {
                                  debugPrint(
                                      "Updating Ui based on the error received");
                                  if (processingSomething == true) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      processingSomething = false;
                                    });
                                  }
                                  if (value ==
                                      "net::ERR_INTERNET_DISCONNECTED") {
                                    debugPrint(
                                        "Updating Ui for net::ERR_INTERNET_DISCONNECTED");
                                    setState(() {
                                      currentStatus = "launchLoadingScreen";
                                      vtopConnectionStatusErrorType =
                                          "net::ERR_INTERNET_DISCONNECTED";
                                      vtopConnectionStatusType = "Error";
                                    });
                                  }
                                },
                              );
                            });
                          },
                          onProcessingSomething: (bool value) {
                            setState(() {
                              processingSomething = value;
                            });
                          },
                        ),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: Duration.zero,
                    ),
                  );
                  setState(() {
                    loggedUserStatus = "classAttendance";
                  });
                } else if (requestType == "Fake") {
                } else if (requestType == "ForDrawer") {
                  debugPrint("Request For Drawer");

                  if (loggedUserStatus != "settings") {
                    Navigator.pushNamed(
                      context,
                      PageRoutes.settings,
                      arguments: SettingsArguments(
                        currentStatus: currentStatus,
                        onWidgetDispose: (bool value) {
                          debugPrint("settings disposed");
                          WidgetsBinding.instance?.addPostFrameCallback(
                            (_) {
                              setState(() {
                                loggedUserStatus = "studentPortalScreen";
                              });
                            },
                          );
                        },
                        timeTableDocument: timeTableDocument,
                        classAttendanceDocument: classAttendanceDocument,
                        screenBasedPixelHeight: screenBasedPixelHeight,
                        screenBasedPixelWidth: screenBasedPixelWidth,
                        semesterSubIdForTimeTable: semesterSubIdForTimeTable,
                        semesterSubIdForAttendance: semesterSubIdForAttendance,
                        onSemesterSubIdForTimeTableChange: (String value) {},
                        onSemesterSubIdForAttendanceChange: (String value) {},
                        onProcessingSomething: (bool value) {
                          setState(() {
                            processingSomething = value;
                          });
                        },
                        onUpdateDefaultTimeTableSemesterId: (String value) {
                          setState(() {
                            semesterSubIdForTimeTable = value;
                          });
                          _saveSemesterSubIdForTimeTable();
                        },
                        onUpdateDefaultAttendanceSemesterId: (String value) {
                          setState(() {
                            semesterSubIdForAttendance = value;
                          });
                          _saveSemesterSubIdForAttendance();
                        },
                        vtopMode: vtopMode,
                        onUpdateDefaultVtopMode: (String value) {
                          setState(() {
                            vtopMode = value;
                          });
                          _saveVtopMode();
                        },
                        headlessWebView: headlessWebView,
                        processingSomething: processingSomething,
                      ),
                    );
                  }
                  setState(() {
                    loggedUserStatus = "settings";
                  });
                }
              });
            } else if (ajaxRequest.responseText!.contains(
                    "You are logged out due to inactivity for more than 15 minutes") ||
                ajaxRequest.responseText!
                    .contains("You have been successfully logged out")) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Session ended',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            } else if (ajaxRequest.status != 200) {
              inActivityOrStatusNot200Response(
                  dialogTitle: 'Request Status != 200',
                  dialogChildrenText: 'Starting new session\nplease wait...');
            }
          } else {
            printWrapped("ajaxRequest: $ajaxRequest");
            printWrapped("ajaxRequest.status: ${ajaxRequest.status}");
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      onLoadStart: (controller, url) async {
        noOfHomePageBuilds = 0;
        noOfLoginAjaxRequests = 0;

        debugPrint("noOfHomePageBuilds onLoadStart: $noOfHomePageBuilds");

        setState(() {
          currentFullUrl = url?.toString() ?? '';
        });
      },
      onLoadStop: (controller, url) async {
        if (processingSomething == true) {
          Navigator.of(context).pop();
          debugPrint("Dialog popped on onLoadStop of HeadlessInAppWebView");
          setState(() {
            processingSomething = false;
          });
        }

        if (url.toString() ==
                "https://vtop.vitbhopal.ac.in/vtop/initialProcess" &&
            await headlessWebView?.webViewController.getProgress() == 100) {
          await headlessWebView?.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then(
            (value) async {
              var document = parse('$value');
              String initialHtml =
                  '<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>';
              String? inactivityResponse = document
                  .getElementById('closedHTML')
                  ?.children[0]
                  .children[0]
                  .children[0]
                  .children[1]
                  .children[0]
                  .children[0]
                  .children[0]
                  .children[0]
                  .innerHtml;

              if (inactivityResponse ==
                      "You are logged out due to inactivity for more than 15 minutes" ||
                  inactivityResponse ==
                      "You have been successfully logged out") {
                runHeadlessInAppWebView(
                  headlessWebView: headlessWebView,
                  onCurrentFullUrl: (String value) {
                    setState(() {
                      currentFullUrl = value;
                    });
                  },
                );
              } else if (value != initialHtml &&
                  document.getElementsByTagName('button').isNotEmpty) {
                // printWrapped("value: $value");
                String? loginButtonText =
                    document.getElementsByTagName('button')[0].text;
                debugPrint("loginButtonText: $loginButtonText");

                if (loginButtonText == 'Login to V-TOP') {
                  noOfHomePageBuilds++;

                  debugPrint(
                      "noOfHomePageBuilds: ${noOfHomePageBuilds.toString()}");
                  //As soon as noOfHomePageBuilds == 1 load login screen and neglect other homepage builds
                  if (noOfHomePageBuilds == 1) {
                    declareAutoFillCaptchaConstants(
                        onCurrentFullUrl: (String value) {
                          currentFullUrl = value;
                        },
                        headlessWebView: headlessWebView,
                        context: context);

                    await headlessWebView?.webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('button')[0].click();");
                  }
                }
              }
            },
          );
        } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/" &&
            await headlessWebView?.webViewController.getProgress() == 100) {
          await headlessWebView?.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            var document = parse('$value');
            String? studentId = document
                .getElementById('page-holder')
                ?.children[0]
                .children[0]
                .children[0]
                .children[1]
                .children[0]
                .children[0]
                .children[0]
                .children[0]
                .children[1]
                .innerHtml;
            if (studentId != null) {
              if (studentId.contains("(STUDENT)")) {
                openStudentProfileAllView(forXAction: 'Logged in');

                studentPortalDocument = document;
                // print(url.toString());
              }
            }
          });
        }
        setState(() {
          currentFullUrl = url?.toString() ?? '';
        });
      },
      onLoadError: (InAppWebViewController controller, Uri? url, int code,
          String message) async {
        debugPrint("error $url: $code, $message");
        if (processingSomething == true) {
          Navigator.of(context).pop();
          setState(() {
            processingSomething = false;
          });
        }
        if (await InternetConnectionChecker().hasConnection) {
          setState(() {
            currentStatus = "launchLoadingScreen";
            vtopConnectionStatusType = "Error";
            vtopConnectionStatusErrorType = message;

            if (vtopConnectionStatusErrorType ==
                    "net::ERR_CONNECTION_TIMED_OUT" &&
                usingVITWifi == null) {
              getWifiTypeDialogBox();
            } else if (vtopConnectionStatusErrorType ==
                    "net::ERR_CONNECTION_TIMED_OUT" &&
                usingVITWifi == true) {
              runDnsSettingsDialogBox();
            }
          });
        } else {
          vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
          vtopConnectionStatusType = "Error";
        }
      },
      onLoadHttpError: (InAppWebViewController controller, Uri? url,
          int statusCode, String description) async {
        debugPrint("HTTP error $url: $statusCode, $description");
      },
    );

    runHeadlessInAppWebView(
        onCurrentFullUrl: (String value) {
          setState(() {
            currentFullUrl = value;
          });
        },
        headlessWebView: headlessWebView);
  }

  @override
  Widget build(BuildContext context) {
    // ↓↓↓↓↓↓↓↓↓↓↓↓ Don't remove them as they are for testing ↓↓↓↓↓↓↓↓↓↓↓↓
    // vtopConnectionStatusErrorType = "net::ERR_INTERNET_DISCONNECTED";
    // vtopConnectionStatusType = "Error";
    // currentStatus = "launchLoadingScreen";
    // currentStatus = "userLoggedIn";
    // currentStatus = "signInScreen";
    // ↑↑↑↑↑↑↑↑↑↑↑↑ Don't remove them as they are for testing ↑↑↑↑↑↑↑↑↑↑↑↑

    debugPrint('darkModeOn: $darkModeOn, theme: $themeMode');
    debugPrint("loggedUserStatus: $loggedUserStatus");
    debugPrint("currentStatus: $currentStatus");
    debugPrint("processingSomething: $processingSomething");
    debugPrint("vtopLoginErrorType: $vtopLoginErrorType");
    debugPrint("vtopMode: $vtopMode");

    chooseHomePageBody();
    chooseHomePageAppbar();
    chooseHomePageDrawer();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // statusBarColor:
        //     darkModeOn! ? Colors.black : Colors.white, //Colors.transparent,
        // statusBarIconBrightness:
        //     darkModeOn! ? Brightness.light : Brightness.dark,
        // statusBarBrightness: !kIsWeb && Platform.isAndroid && darkModeOn!
        //     ? Brightness.dark
        //     : Brightness.light,
        systemNavigationBarColor: darkModeOn! ? Colors.black : Colors.white,
        // systemNavigationBarDividerColor:
        //     darkModeOn! ? Colors.white10 : Colors.grey,
        systemNavigationBarIconBrightness:
            darkModeOn! ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: widget.preferredSize,
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(1.0, 0), end: const Offset(0, 0))
                      .animate(animation),
                  child: child,
                );
              },
              child: appbar),
        ),
        body: Stack(
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(1.0, 0),
                            end: const Offset(0, 0))
                        .animate(animation),
                    child: child,
                  );
                },
                child: body),
            BuildUpdateChecker(
              screenBasedPixelHeight: screenBasedPixelHeight,
              screenBasedPixelWidth: screenBasedPixelWidth,
              onProcessingSomething: (bool value) {
                processingSomething = value;
              },
              shouldAutoCheckUpdateRun: true,
            ),
          ],
        ),
        drawer: Padding(
          padding: EdgeInsets.only(
            right: widgetSizeProvider(
                fixedSize: 80, sizeDecidingVariable: screenBasedPixelWidth),
          ),
          child: drawer,
        ),
      ),
    );
  }
}
