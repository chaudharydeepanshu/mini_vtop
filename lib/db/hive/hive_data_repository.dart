import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveDataRepository {
  late BoxCollection vtopCollection;
  late CollectionBox<String> credentialsBox;

  Future openVTOPDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    vtopCollection = await BoxCollection.open(
      'VTOPBox',
      {'Credentials'},
      path: directory.path,
    );
  }

  openVTOPCredentialsBox() async {
    await openVTOPDb();
    credentialsBox = await vtopCollection.openBox<String>('Credentials');
  }

  updateVTOPCredentialsBox(
      {required String userID, required String password}) async {
    await openVTOPCredentialsBox();
    await credentialsBox.clear();
    // Speed up write actions with transactions
    await vtopCollection.transaction(
      () async {
        await credentialsBox.put('userID', userID);
        await credentialsBox.put('password', password);
      },
      boxNames: ['Credentials'], // By default all boxes become blocked.
      readOnly: false,
    );
  }

  clearVTOPCredentialsBox() async {
    await openVTOPCredentialsBox();
    await credentialsBox.clear();
  }

  Future<String> getVTOPCredentialsBoxUserID() async {
    await openVTOPCredentialsBox();

    print(await credentialsBox.get('userID'));
    return await credentialsBox.get('userID') ?? "";
  }

  Future<String> getVTOPCredentialsBoxPassword() async {
    await openVTOPCredentialsBox();
    return await credentialsBox.get('password') ?? "";
  }
}
