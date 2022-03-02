import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../basicFunctionsAndWidgets/build_semester_selector.dart';
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
    dropdownValue = (widget.arguments.semesterSubId);
  }

  @override
  void dispose() {
    super.dispose();
    // widget.arguments.onTimeTableDocumentDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  late String dropdownValue;

  bool isDialogShowing = false;

  late List semestersHtmlForm = widget.arguments.timeTableDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> semesters = [];

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
                      child: Padding(
                        padding: EdgeInsets.all(
                          widgetSizeProvider(
                              fixedSize: 8,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: widgetSizeProvider(
                                  fixedSize: 2,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                  widgetSizeProvider(
                                      fixedSize: 8,
                                      sizeDecidingVariable:
                                          screenBasedPixelWidth),
                                ),
                                child: Text(
                                  "VTOP Defaults",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widgetSizeProvider(
                                        fixedSize: 16,
                                        sizeDecidingVariable:
                                            screenBasedPixelWidth),
                                  ),
                                ),
                              ),
                              Divider(
                                indent: 0,
                                endIndent: 0,
                                thickness: widgetSizeProvider(
                                    fixedSize: 2,
                                    sizeDecidingVariable:
                                        screenBasedPixelWidth),
                                color: Theme.of(context).colorScheme.outline,
                                height: 0,
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                  widgetSizeProvider(
                                      fixedSize: 8,
                                      sizeDecidingVariable:
                                          screenBasedPixelWidth),
                                ),
                                child: BuildSemesterSelector(
                                  semesters: semesters,
                                  dropdownValue: dropdownValue,
                                  onDropDownChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue = newValue!;
                                    });
                                    widget.arguments.onUpdateDefaultSemesterId
                                        .call(newValue!);
                                  },
                                  screenBasedPixelHeight:
                                      screenBasedPixelHeight,
                                  screenBasedPixelWidth: screenBasedPixelWidth,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class SettingsArguments {
  String? currentStatus;
  ValueChanged<bool>? onTimeTableDocumentDispose;
  dom.Document? timeTableDocument;
  ValueChanged<String>? onSemesterSubIdChange;
  String semesterSubId;
  ValueChanged<bool> onProcessingSomething;
  ValueChanged<String> onUpdateDefaultSemesterId;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  SettingsArguments({
    required this.currentStatus,
    required this.onTimeTableDocumentDispose,
    required this.timeTableDocument,
    required this.onSemesterSubIdChange,
    required this.semesterSubId,
    required this.onProcessingSomething,
    required this.onUpdateDefaultSemesterId,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
