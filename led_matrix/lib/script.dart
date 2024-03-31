// import 'dart:convert';
// import 'dart:io';
// import 'package:image/image.dart';
// import 'dart:math';

// const int NUM_LEDS = 1024;
// List<List<int>> colors = [];
// int? height;
// int? width;
// List<int> gamma8 = [
//     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
//     1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
//     2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
//     5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
//    10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
//    17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
//    25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
//    37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
//    51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
//    69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
//    90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
//   115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
//   144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
//   177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
//   215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255] ; 



// List<List<int>> gammaCorrectFrame(List<List<int>> frame) {
//   for (int i = 0; i < frame.length; i++) {
//     frame[i] = [gamma8[frame[i][0]], gamma8[frame[i][1]], gamma8[frame[i][2]]];
//   }
//   return frame;
// }

// List<List<int>> compressFrames(List<List<List<int>>> frames) {
//   int length = frames.length;
//   List<List<int>> compressedFrames = [];

//   for (int i = length - 1; i > 0; i--) {
//     List<int> frame = deleteIdenticalColors(frames[i - 1], frames[i]);
//     compressedFrames.add(frame);
//   }

//   compressedFrames.add(frames[0]);
//   compressedFrames = compressedFrames.reversed.toList();
//   return compressedFrames;
// }

// bool colorsExists(List<int> color) {
//   for (int i = 0; i < colors.length; i++) {
//     if (colors[i] == color) {
//       return true;
//     }
//   }
//   return false;
// }

// int mappedColors(List<int> color) {
//   for (int i = 0; i < colors.length; i++) {
//     if (colors[i] == color) {
//       return i;
//     }
//   }
//   return -1;
// }

// List<int> deleteIdenticalColors(List<int> prevFrame, List<int> frame) {
//   for (int i = 0; i < frame.length; i++) {
//     if (frame[i] == prevFrame[i]) {
//       frame[i] = -1;
//     }
//   }
//   return frame;
// }

// List<List<int>> compressIdenticalPixelColors(List<int> frame) {
//   List<List<int>> resFrame = [];
//   if (frame.length > 0 && frame[0] != -1) {
//     int length = 1;
//     int startIndex = 0;
//     List<int> currColor = [frame[0]];
//     colors.add(currColor);
//   } else {
//     int length = 0;
//     int startIndex = 0;
//     List<int> currColor = [];
//   }
//   for (int i = 1; i < frame.length; i++) {
//     if (frame[i] == -1) {
//       if (length > 0) {
//         resFrame.add([mappedColors(currColor), startIndex, length]);
//       }
//       length = 0;
//       continue;
//     }
//     if (!colorsExists([frame[i]])) {
//       colors.add([frame[i]]);
//     }
//     if (length == 0) {
//       startIndex = i;
//       length = 1;
//       currColor = [frame[i]];
//     } else {
//       if (frame[i] == currColor[0]) {
//         length = length + 1;
//       } else {
//         resFrame.add([mappedColors(currColor), startIndex, length]);
//         length = 1;
//         currColor = [frame[i]];
//         startIndex = i;
//       }
//     }
//   }
//   if (length > 0) {
//     resFrame.add([mappedColors(currColor), startIndex, length]);
//   }
//   return resFrame;
// }

// List<List<List<int>>> compressGif(List<List<List<int>>> frames) {
//   List<List<int>> compressedFrames = compressFrames(frames);
//   for (int i = 0; i < compressedFrames.length; i++) {
//     compressedFrames[i] = compressIdenticalPixelColors(compressedFrames[i]);
//   }
//   return compressedFrames;
// }
// void convertImageToJson(String inputFilePath, String outputFilePath, int size) {
//   // Open the image file
//   Image? image = decodeImage(File(inputFilePath).readAsBytesSync());

//   // Check if the image is a GIF
//   bool gif = false;
//   if (image is Animation) {
//     gif = true;
//   }

//   int frameNum;
//   List<Image> resizedFrames = [];

//   if (gif) {
//     frameNum = (image as Animation).length;
//   } else {
//     frameNum = 1;
//   }

//   // Iterate over each frame in the input GIF
//   for (int frame = 0; frame < frameNum; frame++) {
//     Image currentFrame = copyResize(image!, width: size, height: size); // Resize the frame to the specified size
//     resizedFrames.add(currentFrame); // Add the resized frame to the list
//   }

//   Map<String, dynamic> gifJson = {};

//   gifJson["width"] = size;
//   gifJson["height"] = size;
//   frameNum = resizedFrames.length < 12 ? resizedFrames.length : 12;
//   gifJson["frames"] = frameNum;

//   // Iterate through frames and pixels, top row first
//   for (int z = 0; z < frameNum; z++) {
//     Image rgbIm = resizedFrames[z];
//     List<List<int>> frame = [];

//     for (int y = 0; y < size; y++) {
//       for (int x = 0; x < size; x++) {
//         // Get RGB values of each pixel
//         int pixel32 = rgbIm.getPixel(x, y);
//         int r = getRed(pixel32);
//         int g = getGreen(pixel32);
//         int b = getBlue(pixel32);

//         frame.add([r, g, b]);
//       }
//     }

//     gifJson["animation"] = frame;
//   }

//   // Write the JSON to the output file
//   File(outputFilePath).writeAsStringSync(jsonEncode(gifJson));
// }