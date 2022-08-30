class StudentProfileModel {
  final String name;
  final String firstName;
  final String dob;
  final String bloodGroup;
  final String rollNo;
  final String applicationNo;
  final String program;
  final String branch;
  final String school;

  StudentProfileModel({
    required this.name,
    required this.firstName,
    required this.dob,
    required this.bloodGroup,
    required this.rollNo,
    required this.applicationNo,
    required this.program,
    required this.branch,
    required this.school,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'StudentProfileModel{name: $name, firstName: $firstName, dob: $dob, bloodGroup: $bloodGroup, rollNo: $rollNo, applicationNo: $applicationNo, program: $program, branch: $branch, school: $school}';
  }
}
