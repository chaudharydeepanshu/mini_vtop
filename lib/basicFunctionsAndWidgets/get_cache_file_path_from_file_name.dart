import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getTemporaryDirectoryPath() async {
  // final directory = await getExternalStorageDirectory();
  final directory = await getTemporaryDirectory();
  String? path = directory.path;
  return path;
}

Future<String> getCacheFilePathFromFileName(String fileName) async {
  String? path = await getTemporaryDirectoryPath();
  String filePath = Platform.isWindows ? '$path\\$fileName' : '$path/$fileName';
  return filePath;
}
