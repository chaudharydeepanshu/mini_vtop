import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../basicFunctionsAndWidgets/build_semester_selector.dart';
import '../basicFunctionsAndWidgets/build_vtop_mode_selector.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
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

class _SettingsState extends State<Settings> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

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
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              sizeDecidingVariable: screenBasedPixelWidth),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Builder(
          builder: (context) => OutlinedButton(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                Theme.of(context).textTheme.button,
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
                              SettingsBox(
                                settingsType: 'Mini VTOP Defaults',
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                settingsBoxChildren: [
                                  BuildSemesterSelector(
                                    semesters: semesters,
                                    dropdownValue: semesterIdDropdownValue,
                                    onDropDownChanged: (String? newValue) {
                                      setState(() {
                                        semesterIdDropdownValue = newValue!;
                                      });
                                      widget.arguments.onUpdateDefaultSemesterId
                                          .call(newValue!);
                                    },
                                    screenBasedPixelHeight:
                                        screenBasedPixelHeight,
                                    screenBasedPixelWidth:
                                        screenBasedPixelWidth,
                                  ),
                                ],
                              ),
                              SettingsBox(
                                settingsType: 'App Defaults',
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                                settingsBoxChildren: [
                                  BuildVtopModeSelector(
                                    semesters: vtopModes,
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

class SettingsBox extends StatefulWidget {
  const SettingsBox({
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
  _SettingsBoxState createState() => _SettingsBoxState();
}

class _SettingsBoxState extends State<SettingsBox> {
  late final double _screenBasedPixelWidth = widget.screenBasedPixelWidth;
  late final double _screenBasedPixelHeight = widget.screenBasedPixelHeight;

  late List<Widget> _settingsBoxChildren = widget.settingsBoxChildren;

  late final String _settingsType = widget.settingsType;

  @override
  void didUpdateWidget(SettingsBox oldWidget) {
    if (oldWidget.settingsBoxChildren != widget.settingsBoxChildren) {
      setState(() {
        _settingsBoxChildren = widget.settingsBoxChildren;
      });
    }
    super.didUpdateWidget(oldWidget);
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
                children: _settingsBoxChildren,
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
