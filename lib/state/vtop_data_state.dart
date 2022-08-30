import 'package:flutter/cupertino.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:html/dom.dart' as dom;

import 'package:mini_vtop/utils/string_cap_extension.dart';

class VTOPData extends ChangeNotifier {
  late StudentProfileModel _studentProfile;
  StudentProfileModel get studentProfile => _studentProfile;

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

    // print(studentProfileViewDocument);

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
}
