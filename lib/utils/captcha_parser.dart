import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;

import 'package:mini_vtop/utils/vit_captcha_characters_bitmaps.dart';

class CropImageParam {
  final List<int> input;
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

List<Uint8List> splitImage(List<int> input) {
  // convert image to image from image package
  imglib.Image image = imglib.decodeImage(input)!;

  // log(image.getBytes().length.toString());
  // log(image.getBytes().toString());

  int x = 0, y = 12;
  int width = (image.width / 6).floor();

  // int height = (image.height / 3).floor();
  // Removing 13 from 45 because the height of character bitmaps is 32 from bottom
  // Also starting y from 12 because its the vertex and it start from 0 so 0..to..12..is 13.
  int height = (image.height - 13).floor();

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
    // refer https://www.nofuss.co.za/programming/dart_png_to_binary_text_format.html
    int bpp = 4;
    Uint8List pixels = imglib.grayscale(img).getBytes();
    List<int> singleBitBytes = [];
    for (int i = 0; i < pixels.length; i += bpp) {
      if ((i / bpp) % width == 0) {
        // sink.write("\n");
      }
      singleBitBytes
          .add((pixels[i] + pixels[i + 1] + pixels[i + 2] > 0) ? 1 : 0);
      // sink.write();
    }

    output.add(singleBitBytes.asUint8List());
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
  // print(charactersMatched);
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
