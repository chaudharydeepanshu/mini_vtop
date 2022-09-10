import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../db/firebase/firebase_data_repository.dart';
import '../models/vtop_contoller_model.dart';

class VTOPControllerState extends ChangeNotifier {
  late VTOPControllerModel _vtopController;
  VTOPControllerModel get vtopController => _vtopController;

  FirebaseDataRepository service = FirebaseDataRepository();

  init() {
    // service
    //     .getControlDocStream()
    //     .listen((DocumentSnapshot<VTOPControllerModel> documentSnapshot) {
    //   VTOPControllerModel? _vtopController = documentSnapshot.data();
    //
    //   // print(firestoreInfo);
    //   //
    //   // setState(() {
    //   //   money = firestoreInfo['earnings'];
    //   // });
    //   notifyListeners();
    // }).onError((e) {
    //   // _vtopController = ;
    //   log(e.toString());
    // });
  }
}
