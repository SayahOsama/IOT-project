// import 'dart:io';
// import 'package:image/image.dart';
// import 'dart:math';

// int NUM_LEDS = 1024;
// List<int> colors = [];
// int height = 0;
// int width = 0;


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
//   215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255];

// void processImage(File _image) {
//   var imageBytes = _image.readAsBytesSync();

//   // Check the file extension
//   String extension = _image.path.split('.').last;

//   // If it is 'gif', then the file is a GIF
//   bool gifFlag = false;
//   int frameNum;
//   Animation? gifImage;

//   if (extension.toLowerCase() == 'gif') {
//     gifFlag = true;
//     print('The file is a GIF');
//     gifImage = GifDecoder().decodeAnimation(imageBytes);
//     frameNum = gifImage?.numFrames ?? 0;
//     print('Number of frames: $frameNum');
//   } else {
//     print('The file is not a GIF');
//     frameNum = 1; // For an image file, the number of frames is always 1
//     print('Number of frames: $frameNum');
//   }

//   List<Image> resizedFrames = [];
//   for (int frame = 0; frame < frameNum; frame++) {
//     var currentFrame = gifImage?.frames[frame];
//     // TODO: Quantize and resize currentFrame
//     // currentFrame = currentFrame.quantize(64);
//     // currentFrame.thumbnail(size, Image.LANCZOS);
//     height = currentFrame?.height ?? -1;
//     width = currentFrame?.width ?? -1;
//     if (currentFrame != null) {
//       resizedFrames.add(currentFrame);
//     }
//   }

//   List frame = [];
//   List frames = [];
//   Map<String, dynamic> gifJson = {};

//   gifJson["width"] = width;
//   gifJson["height"] = height;
//   int frameNumtmp = min(12, resizedFrames.length);
//   gifJson["frames"] = frameNumtmp;

//   for (int z = 0; z < frameNumtmp; z++) {
//     List<List<int>> frame = [];
//     int count = 0;
//     for (int i = 0; i < height; i++) {
//       for (int j = 0; j < width; j++) {
//         int pixel = resizedFrames[z].getPixel(j, i);
//         int r = getRed(pixel);
//         int g = getGreen(pixel);
//         int b = getBlue(pixel);
//         var color = [r, g, b];
//         if (count < NUM_LEDS) {
//           frame.add(color);
//           count++;
//         }
//       }
//     }
//     //correct the frame and add it
//     frames.add(gammaCorrectFrame(frame));
//   }
// }

// // ***********************************************************************************************************

// // gamma_correct_frame
// List<List<int>> gammaCorrectFrame(List<List<int>> frame) {
//   for (int i = 0; i < frame.length; i++) {
//     frame[i] = [gamma8[frame[i][0]], gamma8[frame[i][1]], gamma8[frame[i][2]]];
//   }
//   return frame;
// }


// // compress_frames
// List<List<List<int>>> compressFrames(List<List<List<int>>> frames) {
//   int length = frames.length;
//   List<List<List<int>>> compressedFrames = [];
//   for (int i = length - 1; i > 0; i--) {
//     List<List<int>> frame = deleteIdenticalColors(frames[i - 1], frames[i]);
//     compressedFrames.add(frame);
//   }
//   compressedFrames.add(frames[0]);
//   compressedFrames = compressedFrames.reversed.toList();
//   return compressedFrames;
// }

// // colors_exists
// bool colorsExists(int color) {
//   for (int i = 0; i < colors.length; i++) {
//     if (colors[i] == color) {
//       return true;
//     }
//   }
//   return false;
// }

// // mapped_colors
// int mappedColors(List<int> color) {
//   for (int i = 0; i < colors.length; i++) {
//     if (colors[i] == color[0]) {
//       return i;
//     }
//   }
//   return -1; // return -1 if color is not found in colors
// }


// // delete_indetical_colors
// List<int> deleteIdenticalColors(List<int> prevFrame, List<int> frame) {
//   for (int i = 0; i < frame.length; i++) {
//     if (frame[i] == prevFrame[i]) {
//       frame[i] = -1;
//     }
//   }
//   return frame;
// }




// // compress_identical_pixel_colors
// List<List<int>> compressIdenticalPixelColors(List<int> frame) {
//   List<List<int>> resFrame = [];
//   int length;
//   int startIndex;
//   List<int> currColor;

//   if (frame.isNotEmpty && frame[0] != -1) {
//     length = 1;
//     startIndex = 0;
//     currColor = [frame[0]];
//     colors.add(frame[0]);
//   } else {
//     length = 0;
//     startIndex = 0;
//     currColor = [];
//   }

//   for (int i = 1; i < frame.length; i++) {
//     if (frame[i] == -1) {
//       if (length > 0) {
//         resFrame.add([mappedColors(currColor), startIndex, length]);
//       }
//       length = 0;
//       continue;
//     }
//     if (!colorsExists(frame[i])) {
//       colors.add(frame[i]);
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
//   List<List<List<int>>> compressedFrames = compressFrames(frames);
//   for (int i = 0; i < compressedFrames.length; i++) {
//     compressedFrames[i] = compressIdenticalPixelColors(compressedFrames[i]);
//   }
//   return compressedFrames;
// }




