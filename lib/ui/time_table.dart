import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../basicFunctionsAndWidgets/build_semester_selector_widget_for_timetable.dart';
import '../basicFunctionsAndWidgets/measure_size_of_widget.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class TimeTable extends StatefulWidget {
  static const String routeName = '/timeTable';

  const TimeTable({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  final TimeTableArguments arguments;

  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  late Widget customTimeTable;
  List<TableRow> listOfTableRowsForCustomTimeTable = [];
  var timeTableSize = Size.zero;

  late Widget customSubjectDetailTable;
  List<TableRow> listOfTableRowsForCustomSubjectDetailTable = [];
  var subjectDetailTableSize = Size.zero;

  late List semestersHtmlForm = widget.arguments.timeTableDocument
          ?.getElementById('semesterSubId')
          ?.children ??
      [];

  List<Map<String, String>> semesters = [];

  // var timeTableDocument = widget.arguments.timeTableDocument;
  //
  // @override
  // void didUpdateWidget(TimeTable oldWidget) {
  //   if (oldWidget.arguments.timeTableDocument != widget.arguments.timeTableDocument) {
  //     _currentStatus = widget.currentStatus;
  //   }
  //
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.arguments.timeTableDocument
            ?.getElementById("getStudentDetails")
            ?.children[0]
            .text
            .replaceAll(RegExp('\\s+'), ' ') !=
        "No Record(s) Found") {
      var htmlTimeTable = widget.arguments.timeTableDocument?.getElementById(
          "timeTableStyle"); //document.getElementById("htmlTimeTable");
      List htmlTimeTableTrs = htmlTimeTable?.getElementsByTagName("tr") ?? [];
      // int tdsInTr1 = htmlTimeTableTrs[1].getElementsByTagName("td").length;
      // int tdLength = htmlTimeTableTrs[index].getElementsByTagName("td").length;
      // List<Widget> listOfColumnsForRowWithIndex = [];
      listOfTableRowsForCustomTimeTable = List<TableRow>.generate(1, (int i) {
        debugPrint(
            "no. of tds: ${htmlTimeTableTrs[i].getElementsByTagName("td").length}");
        List<Widget> listOfColumnsForRowWithIndex;

        listOfColumnsForRowWithIndex = List<Widget>.generate(
            htmlTimeTableTrs[i].getElementsByTagName("td").length, (int j) {
          Widget tableRowColumnContainer;
          if (j == 0) {
            debugPrint(
                "legendText: ${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}");
            tableRowColumnContainer = LegendCellWidget(
              legendText:
                  "${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
              screenBasedPixelWidth: screenBasedPixelWidth,
              screenBasedPixelHeight: screenBasedPixelHeight,
            );
          } else {
            debugPrint(
                "CustomTableRowElement: ${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}");
            debugPrint(
                "CustomTableRowElement: ${htmlTimeTableTrs[i + 1].getElementsByTagName("td")[j - 1].text.replaceAll(RegExp('\\s+'), ' ')}");

            tableRowColumnContainer = CustomTableRowElement(
              elementText1:
                  "${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
              elementText2:
                  "${htmlTimeTableTrs[i + 1].getElementsByTagName("td")[j - 1].text.replaceAll(RegExp('\\s+'), ' ')}",
              screenBasedPixelWidth: screenBasedPixelWidth,
              screenBasedPixelHeight: screenBasedPixelHeight,
            );
          }
          return tableRowColumnContainer;
        });

        TableRow tableRow = TableRow(
          children: listOfColumnsForRowWithIndex,
        );

        return tableRow;
      });

      htmlTimeTableTrs.removeRange(0, 2);

      listOfTableRowsForCustomTimeTable = listOfTableRowsForCustomTimeTable +
          List<TableRow>.generate(htmlTimeTableTrs.length, (int i) {
            debugPrint(
                "no. of tds: ${htmlTimeTableTrs[i].getElementsByTagName("td").length}");
            List<Widget> listOfColumnsForRowWithIndex;

            listOfColumnsForRowWithIndex = List<Widget>.generate(
                htmlTimeTableTrs[i].getElementsByTagName("td").length, (int j) {
              Container tableRowColumnContainer = Container(
                decoration: const BoxDecoration(
                    // color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                    ),
                // height: 75,
                // width: 250,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
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
                      "${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                      style: getDynamicTextStyle(
                          textStyle: j != 0
                              ? Theme.of(context).textTheme.bodyText1
                              : Theme.of(context).textTheme.bodyText1?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          sizeDecidingVariable: screenBasedPixelWidth),
                    ),
                  ),
                ),
              );

              return tableRowColumnContainer;
            });

            TableRow tableRow = TableRow(
              children: listOfColumnsForRowWithIndex,
            );

            return tableRow;
          });

      customTimeTable = Table(
        border: TableBorder.all(color: Theme.of(context).colorScheme.outline),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: listOfTableRowsForCustomTimeTable,
      );

      var htmlSubjectDetailTable = widget.arguments.timeTableDocument
              ?.getElementById("studentDetailsList")
              ?.querySelectorAll("table")[
          0]; // Use query selector to obtain a NodeList of all of the <table> elements contained within the element.
      // This will be a list so use the list element to access data

      List htmlSubjectDetailTableTrs =
          htmlSubjectDetailTable?.getElementsByTagName("tr") ?? [];

      var subjectsTotalCreditsTr =
          htmlSubjectDetailTableTrs[htmlSubjectDetailTableTrs.length - 2];

      htmlSubjectDetailTableTrs.removeAt(0);
      htmlSubjectDetailTableTrs.removeRange(
          htmlSubjectDetailTableTrs.length - 2,
          htmlSubjectDetailTableTrs.length);

      listOfTableRowsForCustomSubjectDetailTable =
          List<TableRow>.generate(htmlSubjectDetailTableTrs.length, (int i) {
        debugPrint(
            "no. of tds in tr $i of SubjectDetailTable: ${htmlSubjectDetailTableTrs[i].getElementsByTagName("td").length}");
        List<Widget> listOfColumnsForRowWithIndex;
        if (i < 1) {
          listOfColumnsForRowWithIndex = List<Widget>.generate(
              htmlSubjectDetailTableTrs[i].getElementsByTagName("th").length,
              (int j) {
            Container tableRowColumnContainer = Container(
              decoration: const BoxDecoration(
                  // color: Colors.white,
                  // border: Border.all(color: Colors.black, width: 1),
                  // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
              // height: 75,
              // width: 250,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
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
                    "${htmlSubjectDetailTableTrs[i].getElementsByTagName("th")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                    style: getDynamicTextStyle(
                        textStyle:
                            Theme.of(context).textTheme.bodyText1?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        sizeDecidingVariable: screenBasedPixelWidth),
                  ),
                ),
              ),
            );

            return tableRowColumnContainer;
          });
        } else {
          listOfColumnsForRowWithIndex = List<Widget>.generate(
              htmlSubjectDetailTableTrs[i].getElementsByTagName("td").length,
              (int j) {
            Container tableRowColumnContainer = Container(
              decoration: const BoxDecoration(
                  // color: Colors.white,
                  // border: Border.all(color: Colors.black, width: 1),
                  // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
              // height: 75,
              // width: 250,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
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
                    "${htmlSubjectDetailTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                    style: getDynamicTextStyle(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                        sizeDecidingVariable: screenBasedPixelWidth),
                  ),
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

      customSubjectDetailTable = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            border:
                TableBorder.all(color: Theme.of(context).colorScheme.outline),
            // columnWidths: const <int, TableColumnWidth>{
            //   0: IntrinsicColumnWidth(),
            //   1: FlexColumnWidth(),
            //   2: FixedColumnWidth(64),
            // },
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: listOfTableRowsForCustomSubjectDetailTable,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: widgetSizeProvider(
                  fixedSize: 8, sizeDecidingVariable: screenBasedPixelWidth),
            ),
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white,
                // border: Border(
                //   bottom: BorderSide(color: Colors.black, width: 1),
                //   left: BorderSide(color: Colors.black, width: 1),
                //   right: BorderSide(color: Colors.black, width: 1),
                // ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: widgetSizeProvider(
                      fixedSize: 1,
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
                // border: Border.all(
                //     color: Colors.black, width: screenBasedPixelWidth * 1),
                // borderRadius: const BorderRadius.all(Radius.circular(40));
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
  }

  @override
  void initState() {
    super.initState();
    debugPrint(widget.arguments.timeTableDocument
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
    dropdownValue = (widget.arguments.semesterSubIdForTimeTable);
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
    debugPrint(listOfTableRowsForCustomTimeTable.length.toString());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Tables",
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
                                  // dropdownValue = newValue!;
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
                    widget.arguments.timeTableDocument
                                ?.getElementById("getStudentDetails")
                                ?.children[0]
                                .text
                                .replaceAll(RegExp('\\s+'), ' ') !=
                            "No Record(s) Found"
                        ? Column(
                            children: [
                              TableHeader(
                                tableHeaderText: "Time Table",
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                              ),
                              SizedBox(
                                height: timeTableSize
                                    .height, //(listOfRows.length + 1) * 48 + 1 + 16,
                                width: MediaQuery.of(context).size.width,
                                child: InteractiveViewer(
                                  constrained: false,
                                  scaleEnabled: true,
                                  child: MeasureSize(
                                    onChange: (size) {
                                      setState(() {
                                        timeTableSize = size;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        widgetSizeProvider(
                                            fixedSize: 8,
                                            sizeDecidingVariable:
                                                screenBasedPixelWidth),
                                      ),
                                      child: customTimeTable,
                                    ),
                                  ),
                                ),
                              ),
                              TableHeader(
                                tableHeaderText: "Subject Detail",
                                screenBasedPixelWidth: screenBasedPixelWidth,
                                screenBasedPixelHeight: screenBasedPixelHeight,
                              ),
                              SizedBox(
                                height: subjectDetailTableSize
                                    .height, //(listOfRows.length + 1) * 48 + 1 + 16,
                                width: MediaQuery.of(context).size.width,
                                child: InteractiveViewer(
                                  constrained: false,
                                  scaleEnabled: true,
                                  child: MeasureSize(
                                    onChange: (size) {
                                      setState(() {
                                        subjectDetailTableSize = size;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        widgetSizeProvider(
                                            fixedSize: 8,
                                            sizeDecidingVariable:
                                                screenBasedPixelWidth),
                                      ),
                                      child: customSubjectDetailTable,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const Icon(
                                Icons.error,
                              ),
                              Text(
                                "No Record(s) Found",
                                style: getDynamicTextStyle(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    sizeDecidingVariable:
                                        screenBasedPixelWidth),
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
        // border: Border.all(color: Colors.white, width: 1),
        // borderRadius: const BorderRadius.all(Radius.circular(40));
      ),
      // height: 64,
      // width: 500,
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
    return Container(
      decoration: const BoxDecoration(
          // color: Colors.white,
          // border: Border.all(color: Colors.black, width: 1),
          // borderRadius: const BorderRadius.all(Radius.circular(40));
          ),
      // height: 75,
      // width: 250,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              // color: Colors.white,

              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: widgetSizeProvider(
                      fixedSize: 1,
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
              ),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            // height: 37.5,
            // width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
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
                  elementText1,
                  style: getDynamicTextStyle(
                      textStyle:
                          Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                // color: Colors.white,
                // border: Border.all(color: Colors.black, width: 1),
                // borderRadius: const BorderRadius.all(Radius.circular(40));
                ),
            // height: 37.5,
            // width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
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
                  elementText2,
                  style: getDynamicTextStyle(
                      textStyle:
                          Theme.of(context).textTheme.bodyText1?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      sizeDecidingVariable: screenBasedPixelWidth),
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      decoration: const BoxDecoration(
          // color: Colors.white,
          // border: Border.all(color: Colors.black, width: 1),
          // borderRadius: const BorderRadius.all(Radius.circular(40));
          ),
      height: widgetSizeProvider(
          fixedSize: 75, sizeDecidingVariable: screenBasedPixelHeight),
      // width: 250,
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
                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                sizeDecidingVariable: screenBasedPixelWidth),
          ),
        ),
      ),
    );
  }
}

class TimeTableArguments {
  String? currentStatus;
  ValueChanged<bool>? onWidgetDispose;
  dom.Document? timeTableDocument;
  ValueChanged<String>? onSemesterSubIdChange;
  String semesterSubIdForTimeTable;
  ValueChanged<bool> onProcessingSomething;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  TimeTableArguments({
    required this.currentStatus,
    required this.onWidgetDispose,
    required this.timeTableDocument,
    required this.onSemesterSubIdChange,
    required this.semesterSubIdForTimeTable,
    required this.onProcessingSomething,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
