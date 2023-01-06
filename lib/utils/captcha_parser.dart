import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;
import 'package:minivtop/utils/vit_captcha_characters_bitmaps.dart';

class CropImageParam {
  final Uint8List input;
  CropImageParam(this.input);
}

List<Uint8List> cropImageIsolate(CropImageParam param) {
  // Crop an image in 6 parts horizontally from input (Uint8List in this case).
  List<Uint8List> croppedImages = splitImage(param.input);
  return croppedImages;
}

class CompareBitmapsParam {
  final List<Uint8List> croppedImages;
  CompareBitmapsParam(this.croppedImages);
}

String compareBitmapsIsolate(CompareBitmapsParam param) {
  // Crop an image in 6 parts horizontally from input (Uint8List in this case).
  String matchedBitmaps =
      compareImageBytes(imagesBytesList: param.croppedImages);
  return matchedBitmaps;
}

List<Uint8List> splitImage(Uint8List input) {
  // convert image to image from image package
  imglib.Image image = imglib.decodePng(input)!;

  int x = 0, y = 12;
  int width = (image.width / 6).floor();

  // int height = (image.height / 3).floor();
  // Removing 13 from 45 because the height of character bitmaps is 32 from bottom
  // Also starting y from 12 because its the vertex and it start from 0 so 0..to..12..is 13.
  int height = (image.height - 13).floor();

  // split image to parts
  List<imglib.Image> parts = <imglib.Image>[];

  for (int j = 0; j < 6; j++) {
    parts.add(imglib.copyCrop(image, x: x, y: y, width: width, height: height));
    x += width;
  }

  // convert image from image package to Image Widget to display
  List<Uint8List> output = <Uint8List>[];
  for (var img in parts) {
    // refer https://web.archive.org/web/20230105084440/https://www.nofuss.co.za/programming/dart_png_to_binary_text_format.html
    Uint8List pixels = imglib.grayscale(img).getBytes();
    int bpp = pixels.length ~/ 960;
    List<int> singleBitBytes = [];
    for (int i = 0; i < pixels.length; i += bpp) {
      if ((i / bpp) % width == 0) {}
      singleBitBytes
          .add((pixels[i] + pixels[i + 1] + pixels[i + 2] > 0) ? 1 : 0);
    }

    output.add(Uint8List.fromList(singleBitBytes));
  }

  return output;
}

/// Comparing all 6 parts of image with every bitmap to get most accurate character
String compareImageBytes({required List<Uint8List> imagesBytesList}) {
  List<String> charactersMatched = [];
  for (int i = 0; i < imagesBytesList.length; i++) {
    List<double> charMatchTracker = [];

    for (int j = 0; j < captchaCharactersBytes.length; j++) {
      int bytesSameLocationMatchCount = 0;
      int blacksCount = 0;

      for (int x = 0;
          x < captchaCharactersBytes.values.elementAt(j).length;
          x++) {
        if (imagesBytesList[i][x] == 0 &&
            captchaCharactersBytes.values.elementAt(j)[x] == "0") {
          bytesSameLocationMatchCount++;
        }

        if (captchaCharactersBytes.values.elementAt(j)[x] == "0") {
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
  return charactersMatched.join("");
}

Future<String> getSolvedCaptcha({required Uint8List imageBytes}) async {
  // Get the cropped images from the isolate.
  List<Uint8List> croppedImages =
      await compute(cropImageIsolate, CropImageParam(imageBytes));

  // Get the matched bitmaps from the isolate.
  String matchedBitmaps =
      await compute(compareBitmapsIsolate, CompareBitmapsParam(croppedImages));

  String solvedCaptcha = matchedBitmaps;
  return solvedCaptcha;
}
