import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;

import '../basicFunctions/measure_size_of_widget.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var htmlTimeTable = widget.arguments.timeTableDocument?.getElementById(
        "timeTableStyle"); //document.getElementById("htmlTimeTable");
    List htmlTimeTableTrs = htmlTimeTable?.getElementsByTagName("tr") ?? [];
    // int tdsInTr1 = htmlTimeTableTrs[1].getElementsByTagName("td").length;
    // int tdLength = htmlTimeTableTrs[index].getElementsByTagName("td").length;
    // List<Widget> listOfColumnsForRowWithIndex = [];

    htmlTimeTableTrs.removeRange(0, 2);

    listOfTableRowsForCustomTimeTable =
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
                  left: screenBasedPixelWidth * 15,
                  right: screenBasedPixelWidth * 15,
                  top: screenBasedPixelWidth * 15,
                  bottom: screenBasedPixelWidth * 15),
              child: Text(
                "${htmlTimeTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                style: GoogleFonts.lato(
                  // color: Colors.black,
                  // textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: screenBasedPixelWidth * 15,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
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

    listOfTableRowsForCustomTimeTable.insert(
      0,
      TableRow(
        children: <Widget>[
          LegendCellWidget(
            legendText: "Theory",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "Start",
            elementText2: "End",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "08:30",
            elementText2: "10:00",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "10:05",
            elementText2: "11:35",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "11:40",
            elementText2: "13:10",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "13:15",
            elementText2: "14:45",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "14:50",
            elementText2: "16:20",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "16:25",
            elementText2: "17:55",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
          CustomTableRowElement(
            elementText1: "18:00",
            elementText2: "19:30",
            screenBasedPixelWidth: screenBasedPixelWidth,
            screenBasedPixelHeight: screenBasedPixelHeight,
          ),
        ],
      ),
    );

    customTimeTable = Table(
      border: TableBorder.all(
          color: (Theme.of(context).textTheme.headline1?.color)!),
      // columnWidths: const <int, TableColumnWidth>{
      //   0: IntrinsicColumnWidth(),
      //   1: FlexColumnWidth(),
      //   2: FixedColumnWidth(64),
      // },
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: listOfTableRowsForCustomTimeTable,
    );

    var htmlSubjectDetailTable = widget.arguments.timeTableDocument
        ?.getElementById("studentDetailsList")
        ?.children[1];
    List htmlSubjectDetailTableTrs =
        htmlSubjectDetailTable?.getElementsByTagName("tr") ?? [];

    var subjectsTotalCreditsTr =
        htmlSubjectDetailTableTrs[htmlSubjectDetailTableTrs.length - 2];

    htmlSubjectDetailTableTrs.removeAt(0);
    htmlSubjectDetailTableTrs.removeRange(
        htmlSubjectDetailTableTrs.length - 2, htmlSubjectDetailTableTrs.length);

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
                    left: screenBasedPixelWidth * 15,
                    right: screenBasedPixelWidth * 15,
                    top: screenBasedPixelWidth * 15,
                    bottom: screenBasedPixelWidth * 15),
                child: Text(
                  "${htmlSubjectDetailTableTrs[i].getElementsByTagName("th")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                  style: GoogleFonts.lato(
                    // color: Colors.black,
                    // textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: screenBasedPixelWidth * 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
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
                    left: screenBasedPixelWidth * 15,
                    right: screenBasedPixelWidth * 15,
                    top: screenBasedPixelWidth * 15,
                    bottom: screenBasedPixelWidth * 15),
                child: Text(
                  "${htmlSubjectDetailTableTrs[i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                  style: GoogleFonts.lato(
                    // color: Colors.black,
                    // textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: screenBasedPixelWidth * 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
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
          border: TableBorder.all(
              color: (Theme.of(context).textTheme.headline1?.color)!),
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
          padding: EdgeInsets.only(top: screenBasedPixelWidth * 8.0),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.white,
              // border: Border(
              //   bottom: BorderSide(color: Colors.black, width: 1),
              //   left: BorderSide(color: Colors.black, width: 1),
              //   right: BorderSide(color: Colors.black, width: 1),
              // ),
              border: Border.all(
                  color: (Theme.of(context).textTheme.headline1?.color)!,
                  width: screenBasedPixelWidth * 1),
              // border: Border.all(
              //     color: Colors.black, width: screenBasedPixelWidth * 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: screenBasedPixelWidth * 15,
                      right: screenBasedPixelWidth * 15,
                      top: screenBasedPixelWidth * 15,
                      bottom: screenBasedPixelWidth * 15),
                  child: Text(
                    "${subjectsTotalCreditsTr.getElementsByTagName("td")[0].text.replaceAll(RegExp('\\s+'), ' ')}",
                    style: GoogleFonts.lato(
                      // color: Colors.black,
                      // textStyle: Theme.of(context).textTheme.headline1,
                      fontSize: screenBasedPixelWidth * 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
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
    screenBasedPixelWidth = widget.arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.arguments.screenBasedPixelHeight;
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments.onTimeTableDocumentDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    debugPrint(listOfTableRowsForCustomTimeTable.length.toString());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            "Tables",
            style: GoogleFonts.nunito(
              color: Colors.white,
              textStyle: Theme.of(context).textTheme.headline1,
              fontSize: screenBasedPixelWidth * 25,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xff04294f),
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(
                right: screenBasedPixelWidth * 5,
                top: screenBasedPixelWidth * 8,
                bottom: screenBasedPixelWidth * 8),
            child: SizedBox(
              width: screenBasedPixelWidth * 51,
              height: screenBasedPixelWidth * 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Go back",
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.arrow_back,
                      size: screenBasedPixelWidth * 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableHeader(
              tableHeaderText: "Time Table",
              screenBasedPixelWidth: screenBasedPixelWidth,
              screenBasedPixelHeight: screenBasedPixelHeight,
            ),
            SizedBox(
              height:
                  timeTableSize.height, //(listOfRows.length + 1) * 48 + 1 + 16,
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
                    padding: EdgeInsets.all(screenBasedPixelWidth * 8.0),
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
                    padding: EdgeInsets.all(screenBasedPixelWidth * 8.0),
                    child: customSubjectDetailTable,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      decoration: const BoxDecoration(
        color: Color(0xff04294f),
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
                left: screenBasedPixelWidth * 15,
                right: screenBasedPixelWidth * 15,
                top: screenBasedPixelWidth * 15,
                bottom: screenBasedPixelWidth * 15),
            child: Text(
              tableHeaderText,
              style: GoogleFonts.lato(
                color: Colors.white,
                // textStyle: Theme.of(context).textTheme.headline1,
                fontSize: screenBasedPixelWidth * 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
              ),
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
                    color: (Theme.of(context).textTheme.headline1?.color)!,
                    width: screenBasedPixelWidth * 1),
              ),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            // height: 37.5,
            // width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenBasedPixelWidth * 15,
                  right: screenBasedPixelWidth * 15,
                  top: screenBasedPixelWidth * 15,
                  bottom: screenBasedPixelWidth * 15,
                ),
                child: Text(
                  elementText1,
                  style: GoogleFonts.lato(
                    // color: Colors.black,
                    // textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: screenBasedPixelWidth * 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
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
                  left: screenBasedPixelWidth * 15,
                  right: screenBasedPixelWidth * 15,
                  top: screenBasedPixelWidth * 15,
                  bottom: screenBasedPixelWidth * 15,
                ),
                child: Text(
                  elementText2,
                  style: GoogleFonts.lato(
                    // color: Colors.black,
                    // textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: screenBasedPixelWidth * 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
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
      height: screenBasedPixelHeight * 75,
      // width: 250,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
              left: screenBasedPixelWidth * 15,
              right: screenBasedPixelWidth * 15),
          child: Text(
            legendText,
            style: GoogleFonts.lato(
              // color: Colors.black,
              // textStyle: Theme.of(context).textTheme.headline1,
              fontSize: screenBasedPixelWidth * 15,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class TimeTableArguments {
  String? currentStatus;
  ValueChanged<bool>? onTimeTableDocumentDispose;
  dom.Document? timeTableDocument;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  TimeTableArguments({
    required this.currentStatus,
    required this.onTimeTableDocumentDispose,
    required this.timeTableDocument,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
