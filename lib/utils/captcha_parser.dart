import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;

import 'dart:typed_data';

import 'package:mini_vtop/utils/vit_captcha_characters_bitmaps.dart';

List<Uint8List> splitImage(List<int> input) {
  // convert image to image from image package
  imglib.Image image = imglib.decodeImage(input)!;

  // log(image.getBytes().length.toString());
  // log(image.getBytes().toString());

  int x = 0, y = 13;
  int width = (image.width / 6).floor();

  // int height = (image.height / 3).floor();
  int height = (image.height).floor();
  // print("height: $height");

  // split image to parts
  List<imglib.Image> parts = <imglib.Image>[];

  for (int j = 0; j < 6; j++) {
    parts.add(imglib.copyCrop(image, x, y, width, height));
    x += width;
  }

  // convert image from image package to Image Widget to display
  List<Uint8List> output = <Uint8List>[];
  for (var img in parts) {
    output.add(img.getBytes().asUint8List());
    // log(img.getBytes().length.toString());
    // log(img.getBytes().toString());
  }

  return output;
}

/// Converts a `List<int>` to a [Uint8List].
///
/// Attempts to cast to a [Uint8List] first to avoid creating an unnecessary
/// copy.
extension AsUint8List on List<int> {
  Uint8List asUint8List() {
    final self = this; // Local variable to allow automatic type promotion.
    return (self is Uint8List) ? self : Uint8List.fromList(this);
  }
}

/// Comparing all 6 parts of image with every bitmap to get most accurate character
List<String> compareImageBytes({required List<Uint8List> imagesBytesList}) {
  List<String> charactersMatched = [];
  for (int i = 0; i < imagesBytesList.length; i++) {
    List<double> charMatchTracker = [];

    for (int j = 0; j < captchaCharactersBytes.length; j++) {
      int bytesSameLocationMatchCount = 0;
      int blacksCount = 0;

      for (int x = 0;
          x < captchaCharactersBytes.values.elementAt(j).length;
          x++) {
        int byte = imagesBytesList[i][x] > 0 ? 255 : 0;
        if (byte == 0) {
          if (byte == captchaCharactersBytes.values.elementAt(j)[x]) {
            bytesSameLocationMatchCount++;
          }
        }
        if (captchaCharactersBytes.values.elementAt(j)[x] == 0) {
          blacksCount++;
        }
      }

      charMatchTracker.add((bytesSameLocationMatchCount / blacksCount * 100));
    }

    double largestMatchCount = charMatchTracker.reduce(math.max);
    int indexForLargestCount = charMatchTracker.indexOf(largestMatchCount);
    String mostProbableChar =
        captchaCharactersBytes.keys.elementAt(indexForLargestCount).toString();
    charactersMatched.add(mostProbableChar);
  }
  // print(charactersMatched);
  return charactersMatched;
}

String getSolvedCaptcha({required Uint8List imageBytes}) {
  String solvedCaptcha =
      compareImageBytes(imagesBytesList: splitImage(imageBytes)).join("");
  return solvedCaptcha;
}
