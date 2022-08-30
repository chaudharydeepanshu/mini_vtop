import 'package:flutter/cupertino.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:html/dom.dart';

import '../utils/string_cap_extension.dart';

class VTOPData extends ChangeNotifier {
  late StudentProfileModel _studentProfile;
  StudentProfileModel get studentProfile => _studentProfile;

  setStudentProfile({required Document studentProfileViewDocument}) {
    String name;
    String firstName;
    String lastName;
    String dob;
    String bloodGroup;
    String rollNo;
    String applicationNo;
    String program;
    String branch;
    String school;

    name = CapString().capitalizeFirstOfEach(studentProfileViewDocument
            .getElementById('exTab1')
            ?.children[1]
            .children[0]
            .children[0]
            .children[0]
            .children[0]
            .children[0]
            .children[2]
            .children[1]
            .innerHtml ??
        "👋");
    print(studentProfileViewDocument);

    _studentProfile = StudentProfileModel(
        name: name,
        firstName: name.split(" ")[0],
        dob: "NA",
        bloodGroup: "NA",
        rollNo: "NA",
        applicationNo: "NA",
        program: "NA",
        branch: "NA",
        school: "NA");

    notifyListeners();
  }
}
