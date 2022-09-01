import 'package:flutter/cupertino.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:html/dom.dart' as dom;
import 'package:mini_vtop/utils/string_cap_extension.dart';
import 'package:mini_vtop/models/student_academics_model.dart';

class VTOPData extends ChangeNotifier {
  late StudentProfileModel _studentProfile;
  StudentProfileModel get studentProfile => _studentProfile;

  late StudentAcademicsModel _studentAcademics;
  StudentAcademicsModel get studentAcademics => _studentAcademics;

  void setStudentProfile({required dom.Document studentProfileViewDocument}) {
    String name;
    String dob;
    String bloodGroup;
    String rollNo;
    String applicationNo;
    String program;
    String branch;
    String school;

    dom.Element? tableBody = studentProfileViewDocument
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

    notifyListeners();
  }

  void setStudentAcademics(
      {required dom.Document studentGradeHistoryDocument}) {
    double cgpa;

    dom.Element? tableBody = studentGradeHistoryDocument
        .getElementById('studentGradeView')
        ?.children[1]
        .children[0]
        .children[0]
        .children[2];

    dom.Element? cgpaTable =
        tableBody?.children[8].children[0].children[0].children[1];

    cgpa = double.parse(cgpaTable?.children[2].innerHtml ?? "0");

    _studentAcademics = StudentAcademicsModel(
      cgpa: cgpa,
    );

    notifyListeners();
  }
}
