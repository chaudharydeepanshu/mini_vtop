import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:mini_vtop/basicFunctionsAndWidgets/build_credit_row.dart';
import 'package:url_launcher/url_launcher.dart';
import '../basicFunctionsAndWidgets/build_semester_selector_widget_for_attendance.dart';
import '../basicFunctionsAndWidgets/build_semester_selector_widget_for_timetable.dart';
import '../basicFunctionsAndWidgets/custom_elevated_button.dart';
import '../basicFunctionsAndWidgets/update/build_update_checker_widget.dart';
import '../basicFunctionsAndWidgets/build_vtop_mode_selector_widget.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class Settings extends StatefulWidget {
  static const String routeName = '/settings';

  const Settings({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  final SettingsArguments arguments;

  @override
  _SettingsState createState() => _SettingsState();
}

enum CreditsProperties { creditFor, creditToText, creditUrl }

class _SettingsState extends State<Settings> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String dialogTextForForLeavingApp =
      'Do you want to leave the app to open the url?';
  List<Widget> dialogActionButtonsListForLeavingApp(
      {required String launchUrl, required BuildContext context}) {
    return [
      CustomTextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
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
          launch(launchUrl);
        },
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        size: const Size(20, 50),
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text(
          'Yes',
        ),
      ),
    ];
  }

  List<Map<CreditsProperties, String>> creditsMapList = [
    {
      CreditsProperties.creditFor: "Animations",
      CreditsProperties.creditToText: "Icons8",
      CreditsProperties.creditUrl: "https://icons8.com",
    },
    {
      CreditsProperties.creditFor: "Auto Captcha",
      CreditsProperties.creditToText: "Priyansh Jain",
      CreditsProperties.creditUrl: "https://github.com/Presto412",
    },
  ];

  @override
  void initState() {
    super.initState();
    screenBasedPixelWidth = (widget.arguments.screenBasedPixelWidth);
    screenBasedPixelHeight = (widget.arguments.screenBasedPixelHeight);

    for (int i = 0; i < timeTableSemestersHtmlForm.length; i++) {
      if (timeTableSemestersHtmlForm[i].text.replaceAll(RegExp('\\s+'), ' ') !=
              "-- Choose Semester --" ||
          timeTableSemestersHtmlForm[i]
                  .attributes["value"]
                  .toString()
                  .replaceAll(RegExp('\\s+'), ' ') !=
              "") {
        Map<String, String> semesterDetail = {
          "semesterName": timeTableSemestersHtmlForm[i]
              .text
              .replaceAll(RegExp('\\s+'), ' '),
          "semesterCode": timeTableSemestersHtmlForm[i]
              .attributes["value"]
              .toString()
              .replaceAll(RegExp('\\s+'), ' '),
        };
        timeTableSemesters.add(semesterDetail);
      }
    }
    debugPrint("semesters: $timeTableSemesters");
    timeTableSemesterIdDropdownValue =
        (widget.arguments.semesterSubIdForTimeTable);

    for (int i = 0; i < attendanceSemestersHtmlForm.length; i++) {
      if (attendanceSemestersHtmlForm[i].text.replaceAll(RegExp('\\s+'), ' ') !=
              "-- Choose Semester --" ||
          attendanceSemestersHtmlForm[i]
                  .attributes["value"]
                  .toString()
                  .replaceAll(RegExp('\\s+'), ' ') !=
              "") {
        Map<String, String> semesterDetail = {
          "semesterName": attendanceSemestersHtmlForm[i]
              .text
              .replaceAll(RegExp('\\s+'), ' '),
          "semesterCode": attendanceSemestersHtmlForm[i]
              .attributes["value"]
              .toString()
              .replaceAll(RegExp('\\s+'), ' '),
        };
        attendanceSemesters.add(semesterDetail);
      }
    }
    debugPrint("semesters: $attendanceSemesters");
    attendanceSemesterIdDropdownValue =
        (widget.arguments.semesterSubIdForAttendance);

    vtopModeDropdownValue = (widget.arguments.vtopMode);
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments.onWidgetDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  late String timeTableSemesterIdDropdownValue;
  late String attendanceSemesterIdDropdownValue;
  late String vtopModeDropdownValue;

  bool isDialogShowing = false;

  late List timeTableSemestersHtmlForm = widget.arguments.timeTableDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> timeTableSemesters = [];

  late List attendanceSemestersHtmlForm = widget
          .arguments.classAttendanceDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> attendanceSemesters = [];

  List<String> vtopModes = ['Mini VTOP', 'Full VTOP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
          style: getDynamicTextStyle(
              textStyle: Theme.of(context).appBarTheme.titleTextStyle,
              sizeDecidingVariable: screenBasedPixelWidth),
          textAlign: TextAlign.center,
        ),
        leading: Builder(
          builder: (context) => OutlinedButton(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                getDynamicTextStyle(
                    textStyle: Theme.of(context).appBarTheme.titleTextStyle,
                    sizeDecidingVariable: screenBasedPixelWidth),
              ),
              side: MaterialStateProperty.all<BorderSide>(
                  const BorderSide(color: Colors.transparent)),
              shape: MaterialStateProperty.all<StadiumBorder>(
                  const StadiumBorder()),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: widgetSizeProvider(
                  fixedSize: 24, sizeDecidingVariable: screenBasedPixelWidth),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: widgetSizeProvider(
                            fixedSize: 700,
                            sizeDecidingVariable:
                                widget.arguments.screenBasedPixelWidth),
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (widget.arguments.currentStatus !=
                                          "signInScreen" &&
                                      widget.arguments.currentStatus !=
                                          "launchLoadingScreen")
                                  ? CustomBox(
                                      settingsType: 'Mini VTOP Defaults',
                                      screenBasedPixelWidth:
                                          screenBasedPixelWidth,
                                      screenBasedPixelHeight:
                                          screenBasedPixelHeight,
                                      settingsBoxChildren: [
                                        BuildSemesterSelectorForTimeTable(
                                          dropdownItems: timeTableSemesters,
                                          dropdownValue:
                                              timeTableSemesterIdDropdownValue,
                                          onDropDownChanged:
                                              (String? newValue) {
                                            setState(() {
                                              timeTableSemesterIdDropdownValue =
                                                  newValue!;
                                            });
                                            widget.arguments
                                                .onUpdateDefaultTimeTableSemesterId
                                                .call(newValue!);
                                          },
                                          screenBasedPixelHeight:
                                              screenBasedPixelHeight,
                                          screenBasedPixelWidth:
                                              screenBasedPixelWidth,
                                        ),
                                        BuildSemesterSelectorForAttendance(
                                          dropdownItems: attendanceSemesters,
                                          dropdownValue:
                                              attendanceSemesterIdDropdownValue,
                                          onDropDownChanged:
                                              (String? newValue) {
                                            setState(() {
                                              attendanceSemesterIdDropdownValue =
                                                  newValue!;
                                            });
                                            widget.arguments
                                                .onUpdateDefaultAttendanceSemesterId
                                                .call(newValue!);
                                          },
                                          screenBasedPixelHeight:
                                              screenBasedPixelHeight,
                                          screenBasedPixelWidth:
                                              screenBasedPixelWidth,
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              CustomBox(
                                settingsType: 'App Defaults',
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                settingsBoxChildren: [
                                  BuildVtopModeSelector(
                                    dropdownItems: vtopModes,
                                    dropdownValue: vtopModeDropdownValue,
                                    onDropDownChanged: (String? newValue) {
                                      setState(() {
                                        vtopModeDropdownValue = newValue!;
                                      });
                                      widget.arguments.onUpdateDefaultVtopMode
                                          .call(newValue!);
                                    },
                                    screenBasedPixelHeight:
                                        screenBasedPixelHeight,
                                    screenBasedPixelWidth:
                                        screenBasedPixelWidth,
                                  ),
                                ],
                              ),
                              CustomBox(
                                settingsType: 'General',
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                settingsBoxChildren: [
                                  BuildUpdateChecker(
                                    screenBasedPixelHeight:
                                        screenBasedPixelHeight,
                                    screenBasedPixelWidth:
                                        screenBasedPixelWidth,
                                    onProcessingSomething: (bool value) {
                                      widget.arguments.onProcessingSomething
                                          .call(value);
                                    },
                                    shouldAutoCheckUpdateRun: false,
                                  ),
                                ],
                              ),
                              CustomBox(
                                settingsType: 'Credits & Special Thanks',
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                settingsBoxChildren: List<Widget>.generate(
                                    creditsMapList.length,
                                    (int index) => BuildCreditRow(
                                          screenBasedPixelWidth:
                                              screenBasedPixelWidth,
                                          screenBasedPixelHeight:
                                              screenBasedPixelHeight,
                                          onProcessingSomething: (bool value) {
                                            widget
                                                .arguments.onProcessingSomething
                                                .call(value);
                                          },
                                          creditFor: (creditsMapList[index]
                                              [CreditsProperties.creditFor])!,
                                          creditToText: (creditsMapList[index][
                                              CreditsProperties.creditToText])!,
                                          creditUrl: (creditsMapList[index]
                                              [CreditsProperties.creditUrl])!,
                                        ),
                                    growable: true),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomBox extends StatefulWidget {
  const CustomBox({
    Key? key,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.settingsBoxChildren,
    required this.settingsType,
  }) : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final List<Widget> settingsBoxChildren;
  final String settingsType;

  @override
  _CustomBoxState createState() => _CustomBoxState();
}

class _CustomBoxState extends State<CustomBox> {
  late double _screenBasedPixelWidth;
  late List<Widget> _settingsBoxChildren;
  late String _settingsType;

  @override
  void didUpdateWidget(CustomBox oldWidget) {
    if (oldWidget != widget) {
      setState(() {
        _screenBasedPixelWidth = widget.screenBasedPixelWidth;
        _settingsBoxChildren = widget.settingsBoxChildren;
        _settingsType = widget.settingsType;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _screenBasedPixelWidth = widget.screenBasedPixelWidth;
    _settingsBoxChildren = widget.settingsBoxChildren;
    _settingsType = widget.settingsType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        widgetSizeProvider(
            fixedSize: 8, sizeDecidingVariable: _screenBasedPixelWidth),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: widgetSizeProvider(
                fixedSize: 2, sizeDecidingVariable: _screenBasedPixelWidth),
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(
                widgetSizeProvider(
                    fixedSize: 8, sizeDecidingVariable: _screenBasedPixelWidth),
              ),
              child: Text(
                _settingsType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widgetSizeProvider(
                      fixedSize: 16,
                      sizeDecidingVariable: _screenBasedPixelWidth),
                ),
              ),
            ),
            Divider(
              indent: 0,
              endIndent: 0,
              thickness: widgetSizeProvider(
                  fixedSize: 2, sizeDecidingVariable: _screenBasedPixelWidth),
              color: Theme.of(context).colorScheme.outline,
              height: 0,
            ),
            Padding(
              padding: EdgeInsets.all(
                widgetSizeProvider(
                    fixedSize: 8, sizeDecidingVariable: _screenBasedPixelWidth),
              ),
              child: Column(
                children: List<Widget>.generate(_settingsBoxChildren.length,
                    (int index) {
                  return Column(
                    children: [
                      _settingsBoxChildren[index],
                      index != _settingsBoxChildren.length - 1
                          ? SizedBox(
                              height: widgetSizeProvider(
                                  fixedSize: 8,
                                  sizeDecidingVariable: _screenBasedPixelWidth),
                            )
                          : const SizedBox()
                    ],
                  );
                }, growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsArguments {
  String? currentStatus;
  ValueChanged<bool>? onWidgetDispose;
  dom.Document? timeTableDocument;
  dom.Document? classAttendanceDocument;
  ValueChanged<String>? onSemesterSubIdForTimeTableChange;
  ValueChanged<String>? onSemesterSubIdForAttendanceChange;
  String semesterSubIdForTimeTable;
  String semesterSubIdForAttendance;
  String vtopMode;
  bool processingSomething;
  HeadlessInAppWebView? headlessWebView;
  ValueChanged<bool> onProcessingSomething;
  ValueChanged<String> onUpdateDefaultTimeTableSemesterId;
  ValueChanged<String> onUpdateDefaultAttendanceSemesterId;
  ValueChanged<String> onUpdateDefaultVtopMode;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  SettingsArguments({
    required this.currentStatus,
    required this.onWidgetDispose,
    required this.timeTableDocument,
    required this.classAttendanceDocument,
    required this.onSemesterSubIdForTimeTableChange,
    required this.onSemesterSubIdForAttendanceChange,
    required this.semesterSubIdForTimeTable,
    required this.semesterSubIdForAttendance,
    required this.vtopMode,
    required this.processingSomething,
    required this.headlessWebView,
    required this.onProcessingSomething,
    required this.onUpdateDefaultTimeTableSemesterId,
    required this.onUpdateDefaultAttendanceSemesterId,
    required this.onUpdateDefaultVtopMode,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
