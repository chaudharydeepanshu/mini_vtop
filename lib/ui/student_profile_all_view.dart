import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

class StudentProfileAllView extends StatefulWidget {
  static const String routeName = '/studentProfileAllView';

  const StudentProfileAllView({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  final StudentProfileAllViewArguments arguments;

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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary, // Color(0xff04294f),
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
                "${listOfHeaders[index][0].getElementsByTagName("td")[0].text.replaceAll(RegExp('\\s+'), ' ')}",
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

      List<TableRow> listOfRows =
          List<TableRow>.generate(listOfLists[index].length, (int i) {
        List<Widget> listOfColumnsForRowWithIndex =
            List<Widget>.generate(2, (int j) {
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
                  "${listOfLists[index][i].getElementsByTagName("td")[j].text.replaceAll(RegExp('\\s+'), ' ')}",
                  style: getDynamicTextStyle(
                      textStyle: Theme.of(context).textTheme.bodyText1,
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

      Widget table = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tableHeader,
          Table(
            border:
                TableBorder.all(color: Theme.of(context).colorScheme.outline),
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
    screenBasedPixelWidth = widget.arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.arguments.screenBasedPixelHeight;
  }

  @override
  void didChangeDependencies() {
    var htmlPersonalDetailTable = widget.arguments.studentProfileAllViewDocument
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
        .arguments.studentProfileAllViewDocument
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

    var htmlFamilyDetailTable = widget.arguments.studentProfileAllViewDocument
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

    var htmlProctorDetailTable = widget.arguments.studentProfileAllViewDocument
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
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    widget.arguments.onWidgetDispose?.call(true);
  }

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: screenBasedPixelWidth * 80,
          centerTitle: true,
          title: Text(
            "Student Profile",
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
          bottom: TabBar(
            labelPadding: EdgeInsets.all(
              widgetSizeProvider(
                  fixedSize: 0, sizeDecidingVariable: screenBasedPixelWidth),
            ),
            labelStyle: getDynamicTextStyle(
                textStyle: Theme.of(context).tabBarTheme.labelStyle,
                sizeDecidingVariable: screenBasedPixelWidth),
            labelColor: Theme.of(context).tabBarTheme.labelColor,
            tabs: const [
              Tab(
                child: Text(
                  "Personal",
                  maxLines: 1,
                ),
              ),
              Tab(
                child: Text(
                  "Educational",
                  maxLines: 1,
                ),
              ),
              Tab(
                child: Text(
                  "Family",
                  maxLines: 1,
                ),
              ),
              Tab(
                child: Text(
                  "Proctor",
                  maxLines: 1,
                ),
              ),
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
  ValueChanged<bool>? onWidgetDispose;
  dom.Document? studentProfileAllViewDocument;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  StudentProfileAllViewArguments({
    required this.currentStatus,
    required this.onWidgetDispose,
    required this.studentProfileAllViewDocument,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
