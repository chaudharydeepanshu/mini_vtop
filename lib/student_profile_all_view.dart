import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/dom.dart' as dom;

class StudentProfileAllView extends StatefulWidget {
  static const String routeName = '/studentProfileAllView';

  const StudentProfileAllView({
    Key? key,
    this.arguments,
  }) : super(key: key);

  final StudentProfileAllViewArguments? arguments;

  @override
  _StudentProfileAllViewState createState() => _StudentProfileAllViewState();
}

class _StudentProfileAllViewState extends State<StudentProfileAllView> {
  late List<Widget> listOfTableRows;

  late List<Widget> listOfCustomTables;

  @override
  void initState() {
    super.initState();

    var table = widget.arguments?.studentProfileAllViewDocument
        ?.getElementById("page-wrapper")
        ?.children[0]
        .children[0]
        .children[3]
        .children[1]
        .children[0]
        .children[0]
        .children[0]
        .children[0]; //document.getElementById("table");
    List trs = table?.getElementsByTagName("tr") ?? [];
    // int tdsInTr1 = trs[1].getElementsByTagName("td").length;

    int noOfMiniTablesToCreate = 0;

    List<List> listOfHeaders = [];
    List<List> listOfLists = [];

    List tempList = [];

    for (int i = 0; i < trs.length; i++) {
      if (trs[i].getElementsByTagName("td").length == 1) {
        listOfHeaders.add([trs[i]]);
        noOfMiniTablesToCreate++;
        if (tempList.isNotEmpty) {
          listOfLists.add(tempList);
          tempList = [];
        }
      } else {
        // print(i);
        tempList.add(trs[i]);
        // if (listOfLists.length == noOfMiniTablesToCreate - 1) {
        //   List tempList = [];

        // for (i = i - 1;
        //     i < trs.length && trs[i].getElementsByTagName("td").length != 1;
        //     i++) {
        //   print(trs[i]
        //       .getElementsByTagName("td")[0]
        //       .innerHtml
        //       .replaceAll(RegExp('\\s+'), ' '));
        //   tempList.add(trs[i]);
        // }
        //   listOfLists.add(tempList);
        // }
      }
    }

    if (tempList.isNotEmpty) {
      listOfLists.add(tempList);
      tempList = [];
    }

    debugPrint("listOfLists: ${listOfHeaders.length}");

    listOfCustomTables =
        List<Widget>.generate(noOfMiniTablesToCreate, (int index) {
      debugPrint("listOfLists[$index].length: ${listOfLists[index].length}");
      // int tdLength = trs[index].getElementsByTagName("td").length;
      // List<Widget> listOfColumnsForRowWithIndex = [];

      Widget tableHeader = Container(
        decoration: const BoxDecoration(
          color: Color(0xff04294f),
          // border: Border.all(color: Colors.white, width: 1),
          // borderRadius: const BorderRadius.all(Radius.circular(40));
        ),
        height: 64,
        width: 500,
        child: Center(
          child: Text(
            "${listOfHeaders[index][0].getElementsByTagName("td")[0].innerHtml.replaceAll(RegExp('\\s+'), ' ')}",
            style: GoogleFonts.lato(
              color: Colors.white,
              // textStyle: Theme.of(context).textTheme.headline1,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      );

      List<TableRow> listOfRows =
          List<TableRow>.generate(listOfLists[index].length, (int i) {
        List<Widget> listOfColumnsForRowWithIndex =
            List<Widget>.generate(2, (int j) {
          Container tableRowColumnContainer = Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            height: 75,
            width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "${listOfLists[index][i].getElementsByTagName("td")[j].innerHtml.replaceAll(RegExp('\\s+'), ' ')}",
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

      Widget table = Column(
        children: [
          tableHeader,
          Table(
            border: TableBorder.all(),
            columnWidths: const <int, TableColumnWidth>{
              // 0: IntrinsicColumnWidth(),
              // 1: FlexColumnWidth(),
              // 2: FixedColumnWidth(64),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: listOfRows,
          ),
        ],
      );

      return table;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments?.onShowStudentProfileAllViewDispose?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Student Profile All View",
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
      body: SingleChildScrollView(
        child: Column(
          children: listOfCustomTables,
          // [
          //   Html(
          //       shrinkWrap: true,
          //       data: widget.arguments?.studentProfileAllViewDocument
          //           .getElementById("page-wrapper")
          //           .children[0]
          //           .children[0]
          //           .children[3]
          //           .children[1]
          //           .children[0]
          //           .children[0]
          //           .children[0]
          //           .children[0]
          //           .outerHtml,
          //       style: {
          //         // tables will have the below background color
          //         "table": Style(
          //           backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
          //         ),
          //         // some other granular customizations are also possible
          //         "tr": Style(
          //             border: Border(bottom: BorderSide(color: Colors.grey)),
          //             fontSize: FontSize.xLarge),
          //         "th": Style(
          //           padding: EdgeInsets.all(6),
          //           backgroundColor: Colors.grey,
          //         ),
          //         "td": Style(
          //           padding: EdgeInsets.all(6),
          //           alignment: Alignment.topLeft,
          //         ),
          //         // text that renders h1 elements will be red
          //         "h1": Style(color: Colors.red),
          //       }
          //       //other params
          //       ),
          //
          // ],
        ),
      ),
    );
  }
}

class StudentProfileAllViewArguments {
  String? currentStatus;
  ValueChanged<bool>? onShowStudentProfileAllViewDispose;
  dom.Document? studentProfileAllViewDocument;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;

  StudentProfileAllViewArguments({
    required this.currentStatus,
    required this.onShowStudentProfileAllViewDispose,
    required this.studentProfileAllViewDocument,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
  });
}
