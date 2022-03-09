import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:mini_vtop/basicFunctionsAndWidgets/build_credit_row.dart';
import 'package:url_launcher/url_launcher.dart';
import '../basicFunctionsAndWidgets/build_semester_selector_widget.dart';
import '../basicFunctionsAndWidgets/custom_elevated_button.dart';
import '../basicFunctionsAndWidgets/dailog_box_for_leaving_app.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
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

    for (int i = 0; i < semestersHtmlForm.length; i++) {
      if (semestersHtmlForm[i].text.replaceAll(RegExp('\\s+'), ' ') !=
              "-- Choose Semester --" ||
          semestersHtmlForm[i]
                  .attributes["value"]
                  .toString()
                  .replaceAll(RegExp('\\s+'), ' ') !=
              "") {
        Map<String, String> semesterDetail = {
          "semesterName":
              semestersHtmlForm[i].text.replaceAll(RegExp('\\s+'), ' '),
          "semesterCode": semestersHtmlForm[i]
              .attributes["value"]
              .toString()
              .replaceAll(RegExp('\\s+'), ' '),
        };
        semesters.add(semesterDetail);
      }
    }
    debugPrint("semesters: $semesters");
    semesterIdDropdownValue = (widget.arguments.semesterSubId);
    vtopModeDropdownValue = (widget.arguments.vtopMode);
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments.onWidgetDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  late String semesterIdDropdownValue;
  late String vtopModeDropdownValue;

  bool isDialogShowing = false;

  late List semestersHtmlForm = widget.arguments.timeTableDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> semesters = [];

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
        // backgroundColor: Theme.of(context).colorScheme.surface,
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
                                        BuildSemesterSelector(
                                          dropdownItems: semesters,
                                          dropdownValue:
                                              semesterIdDropdownValue,
                                          onDropDownChanged:
                                              (String? newValue) {
                                            setState(() {
                                              semesterIdDropdownValue =
                                                  newValue!;
                                            });
                                            widget.arguments
                                                .onUpdateDefaultSemesterId
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
  ValueChanged<String>? onSemesterSubIdChange;
  String semesterSubId;
  String vtopMode;
  ValueChanged<bool> onProcessingSomething;
  ValueChanged<String> onUpdateDefaultSemesterId;
  ValueChanged<String> onUpdateDefaultVtopMode;

  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  SettingsArguments({
    required this.currentStatus,
    required this.onWidgetDispose,
    required this.timeTableDocument,
    required this.onSemesterSubIdChange,
    required this.semesterSubId,
    required this.vtopMode,
    required this.onProcessingSomething,
    required this.onUpdateDefaultSemesterId,
    required this.onUpdateDefaultVtopMode,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
