import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/vtop_contoller_model.dart';

class FirebaseDataRepository {
  // 0
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1
  DocumentReference<VTOPControllerModel> documentRef =
      _db.collection("controlDocs").doc("doc1").withConverter(
            fromFirestore: VTOPControllerModel.fromFirestore,
            toFirestore: (VTOPControllerModel userFirebaseModel, _) =>
                userFirebaseModel.toFirestore(),
          );

  // 1
  // final CollectionReference collection =
  //     FirebaseFirestore.instance.collection('pets');

  // 2
  Stream<DocumentSnapshot<VTOPControllerModel>> getControlDocStream() {
    return documentRef.snapshots();
  }
}
