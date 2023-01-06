import 'package:flutter/material.dart';

class StudentTimeTableModel {
  final List<SemesterModel> semesterDropDownDetails;
  final List<TimeTableClassDetailModel> timeTableClassesDetails;
  final List<SubjectDetailModel> subjectsDetails;
  final String timeTableHTMLDoc;

  StudentTimeTableModel({
    required this.semesterDropDownDetails,
    required this.timeTableClassesDetails,
    required this.subjectsDetails,
    required this.timeTableHTMLDoc,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'StudentTimeTableModel{semesterDropDownDetails: $semesterDropDownDetails, timeTableClassesDetails: $timeTableClassesDetails, subjectsDetails: $subjectsDetails, timeTableHTMLDoc: $timeTableHTMLDoc}';
  }
}

class SemesterModel {
  final String semesterName;
  final String semesterCode;
  final bool isSelected;

  SemesterModel({
    required this.semesterName,
    required this.semesterCode,
    required this.isSelected,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'SemesterModel{semesterName: $semesterName, semesterCode: $semesterCode, isSelected: $isSelected}';
  }
}

class TimeTableClassDetailModel {
  final String subjectCode;
  final int classWeekDay;
  final TimeOfDay classStartTime;
  final TimeOfDay classEndTime;

  TimeTableClassDetailModel({
    required this.subjectCode,
    required this.classWeekDay,
    required this.classStartTime,
    required this.classEndTime,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'TimeTableSubjectModel{subjectCode: $subjectCode, classWeekDay: $classWeekDay, "classStartTime": $classStartTime, "classEndTime": $classEndTime}';
  }
}

class SubjectDetailModel {
  final String subjectName;
  final String subjectCode;
  final String subjectType;
  final String classNumber;
  final String subjectSlot;
  final String facultyName;
  final String classVenue;

  SubjectDetailModel({
    required this.subjectName,
    required this.subjectCode,
    required this.subjectType,
    required this.classNumber,
    required this.subjectSlot,
    required this.facultyName,
    required this.classVenue,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'SubjectDetailModel{subjectName: $subjectName, "subjectCode": $subjectCode, "subjectType": $subjectType, "classNumber": $classNumber, "subjectSlot": $subjectSlot, "facultyName": $facultyName, "classVenue": $classVenue}';
  }
}
