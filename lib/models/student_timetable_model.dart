import 'package:flutter/material.dart';

class StudentTimeTableModel {
  final List<TimeTableClassDetailModel> timeTableClassesDetails;
  final List<SubjectDetailModel> subjectsDetails;

  StudentTimeTableModel({
    required this.timeTableClassesDetails,
    required this.subjectsDetails,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'StudentTimeTableModel{timeTableClassesDetails: $timeTableClassesDetails, subjectsDetails: $subjectsDetails}';
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
