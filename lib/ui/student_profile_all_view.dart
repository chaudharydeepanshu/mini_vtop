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
  // late List<Widget> listOfTableRows;
  Map<String, dynamic> createTablesListAndHeadersList(
      {required List listOfTrs}) {
    List<List> listOfHeaders = [];
    List<List> listOfLists = [];
    int noOfMiniTablesToCreate = 0;
    Map<String, dynamic> mapOfListOfHeadersAndLists = {};
    List tempList = [];
    for (int i = 0; i < listOfTrs.length; i++) {
      if (listOfTrs[i].getElementsByTagName("td").length == 1) {
        listOfHeaders.add([listOfTrs[i]]);
        noOfMiniTablesToCreate++;
        if (tempList.isNotEmpty) {
          listOfLists.add(tempList);
          tempList = [];
        }
      } else {
        tempList.add(listOfTrs[i]);
      }
    }
    if (tempList.isNotEmpty) {
      listOfLists.add(tempList);
      tempList = [];
    }

    mapOfListOfHeadersAndLists = {
      "listOfHeaders": listOfHeaders,
      "listOfLists": listOfLists,
      "noOfMiniTablesToCreate": noOfMiniTablesToCreate,
    };

    return mapOfListOfHeadersAndLists;
  }

  List<Widget> listOfCustomTablesCreator(
      {required int noOfMiniTablesToCreate,
      required List listOfLists,
      required List listOfHeaders}) {
    return List<Widget>.generate(noOfMiniTablesToCreate, (int index) {
      debugPrint("listOfLists[$index].length: ${listOfLists[index].length}");

      Widget tableHeader = Container(
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
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 15),
              child: Text(
                "${listOfHeaders[index][0].getElementsByTagName("td")[0].text.replaceAll(RegExp('\\s+'), ' ')}",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  // textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      );

      List<TableRow> listOfRows =
          List<TableRow>.generate(listOfLists[index].length, (int i) {
        List<Widget> listOfColumnsForRowWithIndex =
            List<Widget>.generate(2, (int j) {
          Container tableRowColumnContainer = Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // border: Border.all(color: Colors.black, width: 1),
              // borderRadius: const BorderRadius.all(Radius.circular(40));
            ),
            // height: 75,
            // width: 250,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 15),
                child: Text(
                  "${listOfLists[index][i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tableHeader,
          Table(
            border: TableBorder.all(),
            // columnWidths: const <int, TableColumnWidth>{
            // 0: IntrinsicColumnWidth(),
            // 1: FlexColumnWidth(),
            // 2: FixedColumnWidth(64),
            // },
            defaultColumnWidth: const FlexColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: listOfRows,
          ),
        ],
      );

      return table;
    });
  }

  late List<Widget> listOfPersonalDetailCustomTables;

  late List<Widget> listOfEducationalDetailCustomTables;

  late List<Widget> listOfFamilyDetailCustomTables;

  late List<Widget> listOfProctorDetailCustomTables;

  @override
  void initState() {
    super.initState();

    var htmlPersonalDetailTable = widget
        .arguments?.studentProfileAllViewDocument
        ?.getElementById("page-wrapper")
        ?.children[0]
        .children[0]
        .children[3]
        .children[1]
        .children[0]
        .children[0]
        .children[0]
        .children[0];
    // ?.getElementById("1a")
    // ?.children[0]
    // .children[0]
    // .children[0]; //document.getElementById("htmlPersonalDetailTable");
    List htmlPersonalDetailTrs =
        htmlPersonalDetailTable?.getElementsByTagName("tr") ?? [];
    // int tdsInTr1 = htmlPersonalDetailTrs[1].getElementsByTagName("td").length;

    Map<String, dynamic> mapOfListOfHeadersAndListsForPersonalDetail =
        createTablesListAndHeadersList(listOfTrs: htmlPersonalDetailTrs);
    List<List> listOfPersonalDetailHeaders =
        mapOfListOfHeadersAndListsForPersonalDetail["listOfHeaders"] ?? [];
    List<List> listOfPersonalDetailLists =
        mapOfListOfHeadersAndListsForPersonalDetail["listOfLists"] ?? [];
    int noOfPersonalDetailMiniTablesToCreate =
        mapOfListOfHeadersAndListsForPersonalDetail["noOfMiniTablesToCreate"] ??
            0;

    listOfPersonalDetailCustomTables = listOfCustomTablesCreator(
      listOfLists: listOfPersonalDetailLists,
      listOfHeaders: listOfPersonalDetailHeaders,
      noOfMiniTablesToCreate: noOfPersonalDetailMiniTablesToCreate,
    );

    var htmlEducationalDetailTable = widget
        .arguments?.studentProfileAllViewDocument
        ?.getElementById("page-wrapper")
        ?.children[0]
        .children[0]
        .children[3]
        .children[1]
        .children[1]
        .children[0]
        .children[0]
        .children[0];
    List htmlEducationalDetailTrs =
        htmlEducationalDetailTable?.getElementsByTagName("tr") ?? [];

    Map<String, dynamic> mapOfListOfHeadersAndListsForEducationalDetail =
        createTablesListAndHeadersList(listOfTrs: htmlEducationalDetailTrs);
    List<List> listOfEducationalDetailHeaders =
        mapOfListOfHeadersAndListsForEducationalDetail["listOfHeaders"] ?? [];
    List<List> listOfEducationalDetailLists =
        mapOfListOfHeadersAndListsForEducationalDetail["listOfLists"] ?? [];
    int noOfEducationalDetailMiniTablesToCreate =
        mapOfListOfHeadersAndListsForEducationalDetail[
                "noOfMiniTablesToCreate"] ??
            0;

    listOfEducationalDetailCustomTables = listOfCustomTablesCreator(
      listOfLists: listOfEducationalDetailLists,
      listOfHeaders: listOfEducationalDetailHeaders,
      noOfMiniTablesToCreate: noOfEducationalDetailMiniTablesToCreate,
    );

    var htmlFamilyDetailTable = widget.arguments?.studentProfileAllViewDocument
        ?.getElementById("page-wrapper")
        ?.children[0]
        .children[0]
        .children[3]
        .children[1]
        .children[2]
        .children[0]
        .children[0]
        .children[0];
    List htmlFamilyDetailTrs =
        htmlFamilyDetailTable?.getElementsByTagName("tr") ?? [];

    Map<String, dynamic> mapOfListOfHeadersAndListsForFamilyDetail =
        createTablesListAndHeadersList(listOfTrs: htmlFamilyDetailTrs);
    List<List> listOfFamilyDetailHeaders =
        mapOfListOfHeadersAndListsForFamilyDetail["listOfHeaders"] ?? [];
    List<List> listOfFamilyDetailLists =
        mapOfListOfHeadersAndListsForFamilyDetail["listOfLists"] ?? [];
    int noOfFamilyDetailMiniTablesToCreate =
        mapOfListOfHeadersAndListsForFamilyDetail["noOfMiniTablesToCreate"] ??
            0;

    listOfFamilyDetailCustomTables = listOfCustomTablesCreator(
      listOfLists: listOfFamilyDetailLists,
      listOfHeaders: listOfFamilyDetailHeaders,
      noOfMiniTablesToCreate: noOfFamilyDetailMiniTablesToCreate,
    );

    var htmlProctorDetailTable = widget.arguments?.studentProfileAllViewDocument
        ?.getElementById("page-wrapper")
        ?.children[0]
        .children[0]
        .children[3]
        .children[1]
        .children[3]
        .children[0]
        .children[0]
        .children[0];
    List htmlProctorDetailTrs =
        htmlProctorDetailTable?.getElementsByTagName("tr") ?? [];

    Map<String, dynamic> mapOfListOfHeadersAndListsForProctorDetail =
        createTablesListAndHeadersList(listOfTrs: htmlProctorDetailTrs);
    List<List> listOfProctorDetailHeaders =
        mapOfListOfHeadersAndListsForProctorDetail["listOfHeaders"] ?? [];
    List<List> listOfProctorDetailLists =
        mapOfListOfHeadersAndListsForProctorDetail["listOfLists"] ?? [];
    int noOfProctorDetailMiniTablesToCreate =
        mapOfListOfHeadersAndListsForProctorDetail["noOfMiniTablesToCreate"] ??
            0;

    listOfProctorDetailCustomTables = listOfCustomTablesCreator(
      listOfLists: listOfProctorDetailLists,
      listOfHeaders: listOfProctorDetailHeaders,
      noOfMiniTablesToCreate: noOfProctorDetailMiniTablesToCreate,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments?.onShowStudentProfileAllViewDispose?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Student Profile",
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
          bottom: const TabBar(
            tabs: [
              Tab(text: "Personal"),
              Tab(text: "Educational"),
              Tab(text: "Family"),
              Tab(text: "Proctor"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listOfPersonalDetailCustomTables,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listOfEducationalDetailCustomTables,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listOfFamilyDetailCustomTables,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listOfProctorDetailCustomTables,
              ),
            ),
          ],
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
