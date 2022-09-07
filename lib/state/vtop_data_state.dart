import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:html/dom.dart' as dom;
import 'package:mini_vtop/state/package_info_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/utils/string_cap_extension.dart';
import 'package:mini_vtop/models/student_academics_model.dart';

import '../shared_preferences/preferences.dart';
import 'error_state.dart';

class VTOPData extends ChangeNotifier {
  VTOPData(this.read);
  final Reader read;


  StudentProfileModel? _studentProfile;
  StudentProfileModel? get studentProfile => _studentProfile;

  StudentAcademicsModel? _studentAcademics;
  StudentAcademicsModel? get studentAcademics => _studentAcademics;

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
}
