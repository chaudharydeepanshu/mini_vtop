import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import '../db/firebase/firebase_data_repository.dart';
import '../models/vtop_contoller_model.dart';
import '../shared_preferences/preferences.dart';

class VTOPControllerState extends ChangeNotifier {
  VTOPControllerState(this.read);
  final Reader read;

  late VTOPControllerModel _vtopController;
  VTOPControllerModel get vtopController => _vtopController;

  FirebaseDataRepository service = FirebaseDataRepository();

  late final Preferences readPreferencesProviderValue =
      read(preferencesProvider);

  init() {
    service
        .getControlDocStream()
        .listen((DocumentSnapshot<VTOPControllerModel> documentSnapshot) {
      try {
        _vtopController = documentSnapshot.data()!;

        String vtopControllerAsString =
            jsonEncode(VTOPControllerModel.fromJson(_vtopController.toJson()));

        readPreferencesProviderValue
            .persistVTOPController(vtopControllerAsString);
        // print(vtopControllerAsString);
        notifyListeners();
      } on Exception catch (exception) {
        _vtopController = VTOPControllerModel.fromJson(
            jsonDecode(readPreferencesProviderValue.vtopController));
        notifyListeners();
        log(exception.toString());
      } catch (error) {
        _vtopController = VTOPControllerModel.fromJson(
            jsonDecode(readPreferencesProviderValue.vtopController));
        notifyListeners();
        log(error.toString());
      }
    }).onError((e) {
      _vtopController = VTOPControllerModel.fromJson(
          jsonDecode(readPreferencesProviderValue.vtopController));
      notifyListeners();
      log(e.toString());
    });
  }
}
