import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:minivtop/models/student_profile_model.dart';
import 'package:html/dom.dart' as dom;
import 'package:minivtop/state/package_info_state.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/utils/string_cap_extension.dart';
import 'package:minivtop/models/student_academics_model.dart';

import '../models/student_timetable_model.dart';
import '../shared_preferences/preferences.dart';
import 'error_state.dart';

class VTOPData extends ChangeNotifier {
  VTOPData(this.read);
  final Reader read;

  StudentProfileModel? _studentProfile;
  StudentProfileModel? get studentProfile => _studentProfile;

  StudentAcademicsModel? _studentAcademics;
  StudentAcademicsModel? get studentAcademics => _studentAcademics;

  StudentTimeTableModel? _studentTimeTable;
  StudentTimeTableModel? get studentTimeTable => _studentTimeTable;

  late final Preferences readPreferencesProviderValue =
      read(preferencesProvider);

  late final PackageInfoCalc readPackageInfoCalcProviderValue =
      read(packageInfoCalcProvider);

  late final ErrorStatusState readErrorStatusStateProviderValue =
      read(errorStatusStateProvider);

  Future<void> setStudentProfile(
      {required String studentProfileViewDocument}) async {
    try {
      dom.Document parseDocument = parse(studentProfileViewDocument);

      String name;
      String dob;
      String bloodGroup;
      String rollNo;
      String applicationNo;
      String program;
      String branch;
      String school;

      dom.Element? tableBody = parseDocument
          .getElementById('exTab1')
          ?.children[1]
          .children[0]
          .children[0]
          .children[0]
          .children[0]
          .children[0];

      name = CapString().capitalizeFirstOfEach(
          tableBody?.children[2].children[1].innerHtml ?? "👋");

      dob = CapString()
          .allInCaps(tableBody?.children[3].children[1].innerHtml ?? "-*-");

      bloodGroup = CapString()
          .allInCaps(tableBody?.children[7].children[1].innerHtml ?? "-*-");

      rollNo = CapString()
          .allInCaps(tableBody?.children[16].children[1].innerHtml ?? "-*-");

      applicationNo = CapString()
          .allInCaps(tableBody?.children[1].children[1].innerHtml ?? "-*-");

      program = CapString()
          .allInCaps(tableBody?.children[18].children[1].innerHtml ?? "-*-");

      branch = CapString().capitalizeFirstOfEach(
          tableBody?.children[19].children[1].innerHtml ?? "-*-");

      school = CapString().capitalizeFirstOfEach(
          tableBody?.children[20].children[1].innerHtml ?? "-*-");

      _studentProfile = StudentProfileModel(
          name: name,
          firstName: name.split(" ")[0],
          dob: dob,
          bloodGroup: bloodGroup,
          rollNo: rollNo,
          applicationNo: applicationNo,
          program: program,
          branch: branch,
          school: school);

      readPreferencesProviderValue
          .persistStudentProfileHTMLDoc(studentProfileViewDocument);
    } on Exception catch (exception) {
      log(exception.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentProfile parsing exception: ${exception.toString()}", null,
          reason: 'a non-fatal error');
    } catch (error) {
      log(error.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentProfile parsing error: ${error.toString()}", null,
          reason: 'a non-fatal error');
    }

    notifyListeners();
  }

  Future<void> setStudentAcademics(
      {required String studentGradeHistoryDocument}) async {
    try {
      dom.Document parseDocument = parse(studentGradeHistoryDocument);

      double cgpa;

      dom.Element? tableBody = parseDocument
          .getElementById('studentGradeView')
          ?.children[1]
          .children[0]
          .children[0]
          .children[2];

      dom.Element? cgpaTable =
          tableBody?.children[8].children[0].children[0].children[1];

      String? cgpaElement = cgpaTable?.children[2].innerHtml;

      if (cgpaElement != null) {
        cgpa = double.parse(cgpaElement);

        _studentAcademics = StudentAcademicsModel(
          cgpa: cgpa,
        );

        readPreferencesProviderValue
            .persistAcademicsHTMLDoc(studentGradeHistoryDocument);
      } else {
        _studentAcademics = null;
      }
    } on Exception catch (exception) {
      log(exception.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentAcademics parsing exception: ${exception.toString()}",
          null,
          reason: 'a non-fatal error');
    } catch (error) {
      log(error.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentAcademics parsing error: ${error.toString()}", null,
          reason: 'a non-fatal error');
    }

    notifyListeners();
  }

  Future<void> setStudentTimeTable(
      {required String studentTimeTableDocument}) async {
    try {
      dom.Document parseDocument = parse(studentTimeTableDocument);

      dom.Element? timeTableBody =
          parseDocument.getElementById("timeTableStyle");

      if (timeTableBody != null) {
        // Check for data availability
        //----------------------Time Table-----------------//
        dom.Element? timeTableBody =
            parseDocument.getElementById("timeTableStyle");
        List<dom.Element>? timeTableRows =
            timeTableBody?.getElementsByTagName("tr");
        List<List<String>> timeTableData = [];
        if (timeTableRows != null) {
          List<List<String>> tableData = [];
          for (int i = 0; i < timeTableRows.length; i++) {
            List<dom.Element> tableRowColumns =
                timeTableRows[i].getElementsByTagName("td");
            List<String> tableRowData = [];
            for (int j = 0; j < tableRowColumns.length; j++) {
              String rowData = tableRowColumns[j].text;
              tableRowData.add(rowData);
            }
            tableData.add(tableRowData);
          }
          // log(tableData.toString());
          // Sample tableData looks like this
          /*
          ['Theory', 'Start', '08:30', '10:05', '11:40', '13:15', '14:50', '16:25', '18:00']
          ['End', '10:00', '11:35', '13:10', '14:45', '16:20', '17:55', '19:30']
          ['MON', 'Theory', 'A11-CSE3011-LP-CR006', 'B11-MGT2003-LT-FC-2', 'C11-HUM2001-LT-FC-4', 'A21', 'E13', 'B21-CSE2004-LT-AB102', 'C21']
          ['TUE', 'Theory', 'D11', 'E11-SST2002-P-AB104', 'F11', 'D21-MAT2002-LT-LC023', 'C23-MEE1007-P-AB003', 'E21', 'F21']
          ['WED', 'Theory', 'A12-CSE3011-LP-CR006', 'B12-MGT2003-LT-FC-2', 'C12-HUM2001-LT-FC-4', 'A22', 'F13', 'B22-CSE2004-LT-AB102', 'C22']
          ['THU', 'Theory', 'D12', 'E12', 'F12', 'D22-MAT2002-LT-LC023', 'B23-CSE2004-LT-AB102', 'E22', 'F22']
          ['FRI', 'Theory', 'A13', 'B13', 'C13', 'A23', 'D13-DSN2096-LT-AB408', 'E23', 'D23-MAT2002-LT-LC023']
          ['SAT', 'Theory', 'A14', 'B14', 'C14', 'A24', 'D14', 'E24', 'F23']
        */
          //Sanitizing
          tableData[1].insert(0, 'Theory');
          timeTableData = tableData;
        }
        //----------------------Time Table-----------------//
        //----------------------Subject Table-----------------//
        dom.Element? subjectTableBody = parseDocument
            .getElementById("studentDetailsList")
            ?.querySelectorAll("table")[0];
        List<dom.Element>? subjectTableRows =
            subjectTableBody?.getElementsByTagName("tr");
        List<List<String>> subjectsTableData = [];
        if (subjectTableRows != null) {
          List<List<String>> tableData = [];
          for (int i = 0; i < subjectTableRows.length; i++) {
            List<dom.Element> tableRowColumns =
                subjectTableRows[i].getElementsByTagName("td");
            List<String> tableRowData = [];
            for (int j = 0; j < tableRowColumns.length; j++) {
              String rowData = tableRowColumns[j]
                  .text
                  .replaceAll(RegExp('\\s+'), ' ')
                  .trim();
              tableRowData.add(rowData);
            }
            tableData.add(tableRowData);
          }
          // log(tableData.toString());
          // Sample tableData looks like this
          /*
          []
          []
          ['1', 'General', 'CSE2004 - Theory Of Computation And Compiler Design - Lecture and Tutorial Hours Only', '0 0 0 0 4', 'Regular', 'BL2022231000416', 'Manual', 'B21+B22+B23', 'AB102', 'RAMESH SAHA - SCSE', '25-Jun-2022 16:10', '26-Jun-2022', 'Registered and Approved', '0']
          ['2', 'General', 'CSE3011 - Python Programming - Lecture and Practical Hours Only', '0 0 0 0 3', 'Regular', 'BL2022231000494', 'Manual', 'A11+A12', 'CR006', 'SIDDHARTH SINGH CHOUHAN - SCSE', '25-Jun-2022 16:07', '26-Jun-2022', 'Registered and Approved', '0']
          ['3', 'General', 'DSN2096 - Engineering Design - Lecture and Tutorial Hours Only', '0 0 0 0 2', 'Regular', 'BL2022231000579', 'Manual', 'D13', 'AB408', 'RESEARCH SCHOLAR 02 - SCSE', '25-Jun-2022 16:03', '26-Jun-2022', 'Registered and Approved', '0']
          ['4', 'General', 'DSN3099 - Engineering Project in Community Service - Project Only', '0 0 0 0 2', 'Regular', 'BL2022231000753', 'Manual', 'NIL', 'NIL', 'PARAS JAIN - SCSE', '25-Jun-2022 16:01', '26-Jun-2022', 'Registered and Approved', '0']
          ['5', 'General', 'HUM2001 - Behavioural Science - Lecture and Tutorial Hours Only', '0 0 0 0 3', 'Regular', 'BL2022231000630', 'Manual', 'C11+C12', 'FC-4', 'Rajeev Aggrawal - VITBS', '25-Jun-2022 16:03', '26-Jun-2022', 'Registered and Approved', '0']
          ['6', 'General', 'MAT2002 - Discrete Mathematics And Graph Theory - Lecture and Tutorial Hours Only', '0 0 0 0 4', 'Regular', 'BL2022231000139', 'Manual', 'D21+D22+D23', 'LC023', 'AJAY KUMAR BHURJEE - SASL', '25-Jun-2022 16:12', '26-Jun-2022', 'Registered and Approved', '0']
          ['7', 'General', 'MEE1007 - Engineering Graphics - Practical Hours Only', '0 0 0 0 2', 'Regular', 'BL2022231000357', 'Manual', 'C23', 'AB003', 'NITISH KUMAR - SMEC', '25-Jun-2022 16:13', '26-Jun-2022', 'Registered and Approved', '0']
          ['8', 'General', 'MGT2003 - Technology Entrepreneurship - Lecture and Tutorial Hours Only', '0 0 0 0 3', 'Regular', 'BL2022231000656', 'Manual', 'B11+B12', 'FC-2', 'PRASAD BEGDE - VITBS', '25-Jun-2022 16:39', '26-Jun-2022', 'Registered and Approved', '0']
          ['9', 'General', 'SST2002 - Soft Skills for Engineers - II - Practical Hours Only', '0 0 0 0 1', 'Regular', 'BL2022231000194', 'Manual', 'E11', 'AB104', 'ANITA YADAV - SASL', '25-Jun-2022 16:44', '26-Jun-2022', 'Registered and Approved', '0']
          ['Total Number Of Credits: 24']
          []
        */
          //Sanitizing
          tableData
            ..removeAt(0)
            ..removeAt(0)
            ..removeLast()
            ..removeLast();
          subjectsTableData = tableData;
        }
        //----------------------Subject Table-----------------//
        //----------------------Creating Time Table Model-----------------//
        // log(timeTableData.toString());
        // log(subjectsTableData.toString());
        List<SubjectDetailModel> subjectsDetails = [];
        for (int i = 0; i < subjectsTableData.length; i++) {
          String subjectCodeAndName = subjectsTableData[i][2];
          List<String> list = subjectCodeAndName.split(" - ");
          String subjectCode = list[0];
          String subjectName = list[1];
          String subjectType = list[2];
          String classNumber = subjectsTableData[i][5];
          String subjectSlot = subjectsTableData[i][7];
          String classVenue = subjectsTableData[i][8];
          String facultyName = subjectsTableData[i][9];
          SubjectDetailModel subjectDetail = SubjectDetailModel(
              subjectName: subjectName,
              subjectCode: subjectCode,
              subjectType: subjectType,
              classNumber: classNumber,
              subjectSlot: subjectSlot,
              facultyName: facultyName,
              classVenue: classVenue);
          subjectsDetails.add(subjectDetail);
          // int subjectIndexForBook = subjects.indexWhere((element) =>
          //     element.books
          //         .firstWhereOrNull((e) => e.bookName == result.bookName) !=
          //     null);
          // timeTableData
          //     .where((element) => element.where((e) => e.contains("other")));
        }
        List<TimeTableClassDetailModel> timeTableClassesDetails = [];
        for (int i = 2; i < timeTableData.length; i++) {
          int classWeekDay = i - 2 + 1;
          for (int j = 2; j < timeTableData[i].length; j++) {
            if (timeTableData[i][j].length > 10) {
              // This will make sure that its a class.
              String classText = timeTableData[i][j];
              List<String> list = classText.split("-");
              List<String> classStartTimeSplit = timeTableData[0][j].split(":");
              List<String> classEndTimeSplit = timeTableData[1][j].split(":");
              String subjectCode = list[1];
              TimeOfDay classStartTime = TimeOfDay(
                  hour: int.parse(classStartTimeSplit[0]),
                  minute: int.parse(classStartTimeSplit[1]));
              TimeOfDay classEndTime = TimeOfDay(
                  hour: int.parse(classEndTimeSplit[0]),
                  minute: int.parse(classEndTimeSplit[1]));
              TimeTableClassDetailModel timeTableClass =
                  TimeTableClassDetailModel(
                      subjectCode: subjectCode,
                      classWeekDay: classWeekDay,
                      classStartTime: classStartTime,
                      classEndTime: classEndTime);
              timeTableClassesDetails.add(timeTableClass);
            }
          }
          String subjectCodeAndName = subjectsTableData[i][2];
          List<String> list = subjectCodeAndName.split(" - ");
          String subjectCode = list[0];
          String subjectName = list[1];
          String subjectType = list[2];
          String classNumber = subjectsTableData[i][5];
          String subjectSlot = subjectsTableData[i][7];
          String classVenue = subjectsTableData[i][8];
          String facultyName = subjectsTableData[i][9];
          SubjectDetailModel subjectDetail = SubjectDetailModel(
              subjectName: subjectName,
              subjectCode: subjectCode,
              subjectType: subjectType,
              classNumber: classNumber,
              subjectSlot: subjectSlot,
              facultyName: facultyName,
              classVenue: classVenue);
          subjectsDetails.add(subjectDetail);
        }
        _studentTimeTable = StudentTimeTableModel(
            timeTableClassesDetails: timeTableClassesDetails,
            subjectsDetails: subjectsDetails);

        readPreferencesProviderValue
            .persistTimeTableHTMLDoc(studentTimeTableDocument);
      } else {
        dom.Element? studentDetailsListBody =
            parseDocument.getElementById("getStudentDetails");
        if (studentDetailsListBody != null) {
          if (studentDetailsListBody.children[0].text == "No Record(s) Found") {
            _studentTimeTable = StudentTimeTableModel(
                timeTableClassesDetails: [], subjectsDetails: []);
          } else {
            _studentTimeTable = null;
          }
        } else {
          _studentTimeTable = null;
        }
      }
      // log("TimeTableModel: ${_studentTimeTable.toString()}");
      //----------------------Creating Time Table Model-----------------//
    } on Exception catch (exception) {
      log(exception.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentTimeTable parsing exception: ${exception.toString()}",
          null,
          reason: 'a non-fatal error');
    } catch (error) {
      log(error.toString());

      readErrorStatusStateProviderValue.update(
          status: ErrorStatus.docParsingError);
      await FirebaseCrashlytics.instance.recordError(
          "setStudentTimeTable parsing error: ${error.toString()}", null,
          reason: 'a non-fatal error');
    }

    notifyListeners();
  }
}
