import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadFile({
  required uri,
  required String? releaseSavePath,
  required bool downloading,
  required CancelToken cancelToken,
  required String progress,
  required bool isDialogShowing,
  required double? downloadProgress,
  required bool isDownloaded,
  required BuildContext context,
  required String? releaseDownloadUrl,
  required String openResult,
  required ValueChanged<String> onProgress,
  required ValueChanged<bool> onIsDownloaded,
  required ValueChanged<bool> onDownloading,
  required ValueChanged<String> onOpenResult,
  required ValueChanged<bool> onIsDialogBoxShowing,
}) async {
  debugPrint("isDialogShowing: $isDialogShowing");
  final targetFile = Directory(releaseSavePath!);
  if (targetFile.existsSync()) {
    targetFile.deleteSync(recursive: true);
  } else {
    debugPrint("File with path $releaseSavePath doesn't exist");
  }

  downloading = true;
  onDownloading.call(downloading);

  Dio dio = Dio();

  dio.download(
    uri,
    releaseSavePath,
    cancelToken: cancelToken,
    onReceiveProgress: (rcv, total) {
      // print(
      //     'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

      progress = ((rcv / total) * 100).toStringAsFixed(0);
      onProgress.call(progress);

      if (progress == '100') {
        isDownloaded = true;
        onIsDownloaded.call(isDownloaded);
      } else if (double.parse(progress) < 100) {}
    },
    deleteOnError: true,
  ).then((_) {
    print("Run then");
    if (progress == '100') {
      isDownloaded = true;
      print("Download completed");
      onIsDownloaded.call(isDownloaded);
    }

    downloading = false;
    onDownloading.call(downloading);

    print(isDialogShowing);
    print(isDownloaded);
    if (isDialogShowing == true && isDownloaded == true) {
      Navigator.of(context).pop();
      isDialogShowing = false;
      onIsDialogBoxShowing.call(isDialogShowing);
      Future.delayed(const Duration(milliseconds: 1000), () {
        debugPrint("Going to pop dialog and open file");
        openFile(
            openResult: openResult,
            onOpenResult: (String value) {
              onOpenResult.call(value);
            },
            releaseSavePath: releaseSavePath);
      });
    }
  }).catchError((e) {
    if (CancelToken.isCancel(e)) {
      debugPrint('$releaseDownloadUrl: $e');
    }
  });
}

Future<void> openFile({
  required String releaseSavePath,
  required String openResult,
  required ValueChanged<String> onOpenResult,
}) async {
  final result = await OpenFile.open(releaseSavePath);
  openResult = "type=${result.type}  message=${result.message}";
  onOpenResult.call(openResult);
  debugPrint(openResult);
}
