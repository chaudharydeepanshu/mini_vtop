import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageRepository {
  late FlutterSecureStorage flutterSecureStorage;

  void createStorage() {
    flutterSecureStorage = const FlutterSecureStorage();
  }

  updateVTOPCredentials(
      {required String userID, required String userPassword}) async {
    clearVTOPCredentials();

    await flutterSecureStorage.write(key: 'USER_ID', value: userID);
    await flutterSecureStorage.write(key: 'USER_PASSWORD', value: userPassword);
  }

  clearVTOPCredentials() async {
    createStorage();
    await flutterSecureStorage.deleteAll();
  }

  Future<String> getVTOPCredentialsUserID() async {
    createStorage();
    String? userID = await flutterSecureStorage.read(key: 'USER_ID');

    return userID ?? "";
  }

  Future<String> getVTOPCredentialsUserPassword() async {
    createStorage();
    String? password = await flutterSecureStorage.read(key: 'USER_PASSWORD');

    return password ?? "";
  }
}
