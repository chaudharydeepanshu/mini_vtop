class StudentAttendanceModel {
  final List<SubjectAttendanceDetailModel> subjectsAttendanceDetails;

  StudentAttendanceModel({
    required this.subjectsAttendanceDetails,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'StudentAttendanceModel{subjectsAttendanceDetails: $subjectsAttendanceDetails}';
  }
}

class SubjectAttendanceDetailModel {
  final String subjectName;
  final String subjectCode;
  final String subjectType;
  final String subjectSlot;
  final String facultyCode;
  final String facultyName;
  final int attendedClasses;
  final int totalClasses;
  final double percentOfAttendance;

  SubjectAttendanceDetailModel({
    required this.subjectName,
    required this.subjectCode,
    required this.subjectType,
    required this.subjectSlot,
    required this.facultyCode,
    required this.facultyName,
    required this.attendedClasses,
    required this.totalClasses,
    required this.percentOfAttendance,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'SubjectAttendanceDetailModel{subjectName: $subjectName, "subjectCode": $subjectCode, "subjectType": $subjectType, "subjectSlot": $subjectSlot, "facultyCode": $facultyCode, "facultyName": $facultyName}';
  }
}
