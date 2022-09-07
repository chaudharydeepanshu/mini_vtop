import 'package:cloud_firestore/cloud_firestore.dart';

class VTOPControllerModel {
  String? semesterSubId;

  VTOPControllerModel({
    this.semesterSubId,
  });

  factory VTOPControllerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return VTOPControllerModel(
      semesterSubId: data?['semesterSubId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (semesterSubId != null) "semesterSubId": semesterSubId,
    };
  }

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() => 'VTOPControllerModel{semesterSubId: $semesterSubId}';
}
