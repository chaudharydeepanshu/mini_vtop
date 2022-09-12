import 'package:cloud_firestore/cloud_firestore.dart';

class VTOPControllerModel {
  String timeTableID;
  String attendanceID;

  VTOPControllerModel({
    required this.timeTableID,
    required this.attendanceID,
  });

  factory VTOPControllerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return VTOPControllerModel(
      timeTableID: data?['timeTableID'],
      attendanceID: data?['attendanceID'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "timeTableID": timeTableID,
      "attendanceID": attendanceID,
    };
  }

  factory VTOPControllerModel.fromJson(Map<String, dynamic> parsedJson) {
    return VTOPControllerModel(
      timeTableID: parsedJson['timeTableID'],
      attendanceID: parsedJson['attendanceID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "timeTableID": timeTableID,
      "attendanceID": attendanceID,
    };
  }

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() =>
      'VTOPControllerModel{timeTableID: $timeTableID, attendanceID: $attendanceID}';
}
