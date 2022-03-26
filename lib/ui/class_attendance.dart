import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import '../basicFunctionsAndWidgets/build_semester_selector_widget_for_timetable.dart';
import '../basicFunctionsAndWidgets/measure_size_of_widget.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class ClassAttendance extends StatefulWidget {
  static const String routeName = '/classAttendance';

  const ClassAttendance({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  final ClassAttendanceArguments arguments;

  @override
  _ClassAttendanceState createState() => _ClassAttendanceState();
}

class _ClassAttendanceState extends State<ClassAttendance> {
  late Widget customClassAttendanceDetailTable;
  List<TableRow> listOfTableRowsForCustomClassAttendanceDetailTable = [];
  var classAttendanceDetailTableSize = Size.zero;

  late List semestersHtmlForm = widget.arguments.classAttendanceDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> semesters = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var htmlClassAttendanceDetailTable = widget
            .arguments.classAttendanceDocument
            ?.getElementById("getStudentDetails")
            ?.querySelectorAll("table")[
        0]; // Use query selector to obtain a NodeList of all of the <table> elements contained within the element.
    // This will be a list so use the list element to access data

    List htmlClassAttendanceDetailTableTrs =
        htmlClassAttendanceDetailTable?.getElementsByTagName("tr") ?? [];

    var subjectsTotalCreditsTr = htmlClassAttendanceDetailTableTrs[
        htmlClassAttendanceDetailTableTrs.length - 1];

    htmlClassAttendanceDetailTableTrs
        .removeAt(htmlClassAttendanceDetailTableTrs.length - 1);

    listOfTableRowsForCustomClassAttendanceDetailTable =
        List<TableRow>.generate(htmlClassAttendanceDetailTableTrs.length,
            (int i) {
      debugPrint(
          "no. of tds in tr $i of ClassAttendanceDetailTable: ${htmlClassAttendanceDetailTableTrs[i].getElementsByTagName("td").length}");
      List<Widget> listOfColumnsForRowWithIndex;
      if (i < 1) {
        listOfColumnsForRowWithIndex = List<Widget>.generate(
            htmlClassAttendanceDetailTableTrs[i]
                .getElementsByTagName("th")
                .length, (int j) {
          Widget tableRowColumnContainer = Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                right: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                top: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                bottom: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              ),
              child: Text(
                "${htmlClassAttendanceDetailTableTrs[i].getElementsByTagName("th")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
          );

          return tableRowColumnContainer;
        });
      } else {
        listOfColumnsForRowWithIndex = List<Widget>.generate(
            htmlClassAttendanceDetailTableTrs[i]
                .getElementsByTagName("td")
                .length, (int j) {
          Widget tableRowColumnContainer = Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                right: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                top: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                bottom: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              ),
              child: Text(
                "${htmlClassAttendanceDetailTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1,
                    sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
          );

          return tableRowColumnContainer;
        });
      }
      TableRow tableRow = TableRow(
        children: listOfColumnsForRowWithIndex,
      );

      return tableRow;
    });

    customClassAttendanceDetailTable = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          border: TableBorder.all(color: Theme.of(context).colorScheme.outline),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: listOfTableRowsForCustomClassAttendanceDetailTable,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: widgetSizeProvider(
                fixedSize: 8, sizeDecidingVariable: screenBasedPixelWidth),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: widgetSizeProvider(
                    fixedSize: 1, sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: widgetSizeProvider(
                        fixedSize: 15,
                        sizeDecidingVariable: screenBasedPixelWidth),
                    right: widgetSizeProvider(
                        fixedSize: 15,
                        sizeDecidingVariable: screenBasedPixelWidth),
                    top: widgetSizeProvider(
                        fixedSize: 15,
                        sizeDecidingVariable: screenBasedPixelWidth),
                    bottom: widgetSizeProvider(
                        fixedSize: 15,
                        sizeDecidingVariable: screenBasedPixelWidth),
                  ),
                  child: Text(
                    "${subjectsTotalCreditsTr.getElementsByTagName("td")[0].text.replaceAll(RegExp('\\s+'), ' ')}",
                    style: getDynamicTextStyle(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                        sizeDecidingVariable: screenBasedPixelWidth),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.arguments.classAttendanceDocument
        ?.getElementById("getStudentDetails")
        ?.children[0]
        .text
        .replaceAll(RegExp('\\s+'), ' '));
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
    dropdownValue = (widget.arguments.semesterSubIdForAttendance);
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments.onWidgetDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  late String dropdownValue;

  bool isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    debugPrint(
        listOfTableRowsForCustomClassAttendanceDetailTable.length.toString());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Attendance",
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
                      child: Padding(
                        padding: EdgeInsets.all(
                          widgetSizeProvider(
                              fixedSize: 8,
                              sizeDecidingVariable: screenBasedPixelWidth),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              widgetSizeProvider(
                                  fixedSize: 8,
                                  sizeDecidingVariable: screenBasedPixelWidth),
                            ),
                            child: BuildSemesterSelectorForTimeTable(
                              dropdownItems: semesters,
                              dropdownValue: dropdownValue,
                              onDropDownChanged: (String? newValue) {
                                setState(() {
                                  WidgetsBinding.instance
                                      ?.addPostFrameCallback((_) {
                                    widget.arguments.onProcessingSomething.call(
                                        true); //then set processing something true for the new loading dialog
                                    customAlertDialogBox(
                                      isDialogShowing: isDialogShowing,
                                      context: context,
                                      onIsDialogShowing: (bool value) {
                                        setState(() {
                                          isDialogShowing = value;
                                        });
                                      },
                                      dialogTitle: 'Requesting Data',
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
                                                  fixedSize: 4.0,
                                                  sizeDecidingVariable:
                                                      screenBasedPixelWidth),
                                            ),
                                          ),
                                          Text(
                                            'Please wait...',
                                            style: getDynamicTextStyle(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.60)),
                                                sizeDecidingVariable:
                                                    screenBasedPixelWidth),
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
                                        widget.arguments.onProcessingSomething
                                            .call(value);
                                      },
                                    ).then((_) => isDialogShowing = false);
                                  });
                                  widget.arguments.onSemesterSubIdChange
                                      ?.call(newValue!);
                                });
                              },
                              screenBasedPixelHeight: screenBasedPixelHeight,
                              screenBasedPixelWidth: screenBasedPixelWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        TableHeader(
                          tableHeaderText: "Attendance Table",
                          screenBasedPixelWidth: screenBasedPixelWidth,
                          screenBasedPixelHeight: screenBasedPixelHeight,
                        ),
                        SizedBox(
                          height: classAttendanceDetailTableSize.height,
                          width: MediaQuery.of(context).size.width,
                          child: InteractiveViewer(
                            constrained: false,
                            scaleEnabled: true,
                            child: MeasureSize(
                              onChange: (size) {
                                setState(() {
                                  classAttendanceDetailTableSize = size;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(
                                  widgetSizeProvider(
                                      fixedSize: 8,
                                      sizeDecidingVariable:
                                          screenBasedPixelWidth),
                                ),
                                child: customClassAttendanceDetailTable,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({
    Key? key,
    required this.tableHeaderText,
    required this.screenBasedPixelHeight,
    required this.screenBasedPixelWidth,
  }) : super(key: key);

  final String tableHeaderText;
  final double screenBasedPixelHeight;
  final double screenBasedPixelWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              right: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              top: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              bottom: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
            ),
            child: Text(
              tableHeaderText,
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                  sizeDecidingVariable: screenBasedPixelWidth),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTableRowElement extends StatelessWidget {
  const CustomTableRowElement({
    Key? key,
    required this.elementText1,
    required this.elementText2,
    required this.screenBasedPixelHeight,
    required this.screenBasedPixelWidth,
  }) : super(key: key);

  final String elementText1;
  final String elementText2;
  final double screenBasedPixelHeight;
  final double screenBasedPixelWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: widgetSizeProvider(
                    fixedSize: 1, sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                right: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                top: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
                bottom: widgetSizeProvider(
                    fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              ),
              child: Text(
                elementText1,
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1,
                    sizeDecidingVariable: screenBasedPixelWidth),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              right: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              top: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
              bottom: widgetSizeProvider(
                  fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
            ),
            child: Text(
              elementText2,
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.bodyText1,
                  sizeDecidingVariable: screenBasedPixelWidth),
            ),
          ),
        ),
      ],
    );
  }
}

class LegendCellWidget extends StatelessWidget {
  const LegendCellWidget({
    Key? key,
    required this.legendText,
    required this.screenBasedPixelHeight,
    required this.screenBasedPixelWidth,
  }) : super(key: key);

  final String legendText;
  final double screenBasedPixelHeight;
  final double screenBasedPixelWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widgetSizeProvider(
          fixedSize: 75, sizeDecidingVariable: screenBasedPixelHeight),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left: widgetSizeProvider(
                fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
            right: widgetSizeProvider(
                fixedSize: 15, sizeDecidingVariable: screenBasedPixelWidth),
          ),
          child: Text(
            legendText,
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.bodyText1,
                sizeDecidingVariable: screenBasedPixelWidth),
          ),
        ),
      ),
    );
  }
}

class ClassAttendanceArguments {
  String? currentStatus;
  ValueChanged<bool>? onWidgetDispose;
  dom.Document? classAttendanceDocument;
  ValueChanged<String>? onSemesterSubIdChange;
  String semesterSubIdForAttendance;
  ValueChanged<bool> onProcessingSomething;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  ClassAttendanceArguments({
    required this.currentStatus,
    required this.onWidgetDispose,
    required this.classAttendanceDocument,
    required this.onSemesterSubIdChange,
    required this.semesterSubIdForAttendance,
    required this.onProcessingSomething,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
