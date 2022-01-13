import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;

class TimeTable extends StatefulWidget {
  static const String routeName = '/timeTable';

  const TimeTable({
    Key? key,
    this.arguments,
  }) : super(key: key);

  final TimeTableArguments? arguments;

  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  late List<Widget> listOfTableRows;

  late Widget customTable;

  @override
  void initState() {
    super.initState();

    var table = widget.arguments?.timeTableDocument
        ?.getElementById("timeTableStyle"); //document.getElementById("table");
    List trs = table?.getElementsByTagName("tr") ?? [];
    // int tdsInTr1 = trs[1].getElementsByTagName("td").length;
    // int tdLength = trs[index].getElementsByTagName("td").length;
    // List<Widget> listOfColumnsForRowWithIndex = [];

    trs.removeRange(0, 2);
    List<TableRow> listOfRows = [];

    listOfRows = List<TableRow>.generate(trs.length, (int i) {
      debugPrint("no. of tds: ${trs[i].getElementsByTagName("td").length}");
      List<Widget> listOfColumnsForRowWithIndex;

      listOfColumnsForRowWithIndex = List<Widget>.generate(
          trs[i].getElementsByTagName("td").length, (int j) {
        Container tableRowColumnContainer = Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            // border: Border.all(color: Colors.black, width: 1),
            // borderRadius: const BorderRadius.all(Radius.circular(40));
          ),
          height: 75,
          // width: 250,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "${trs[i].getElementsByTagName("td")[j].innerHtml.replaceAll(RegExp('\\s+'), ' ')}",
                style: GoogleFonts.lato(
                  color: Colors.black,
                  // textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: 15,
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

    listOfRows.insert(
      0,
      TableRow(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  "Theory",
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    // textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "Start",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "End",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "08:30",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "10:00",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "10:05",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "11:35",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "11:40",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "13:10",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "13:15",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "14:45",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "14:50",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "16:20",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "16:25",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "17:55",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            // width: 250,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "18:00",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.black, width: 1),
                    // borderRadius: const BorderRadius.all(Radius.circular(40));
                  ),
                  height: 37.5,
                  // width: 250,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "19:30",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          // textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    customTable = Table(
      border: TableBorder.all(),
      // columnWidths: const <int, TableColumnWidth>{
      //   0: IntrinsicColumnWidth(),
      //   1: FlexColumnWidth(),
      //   2: FixedColumnWidth(64),
      // },
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: listOfRows,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments?.onTimeTableDocumentDispose?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Time Table",
          style: GoogleFonts.nunito(
            color: Colors.white,
            textStyle: Theme.of(context).textTheme.headline1,
            fontSize: 25,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff04294f),
      ),
      body: SizedBox(
        height: 450 + 16,
        child: InteractiveViewer(
            constrained: false,
            scaleEnabled: true,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: customTable,
            )),
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

  TimeTableArguments({
    required this.currentStatus,
    required this.onTimeTableDocumentDispose,
    required this.timeTableDocument,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
  });
}
