import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Estimator {
  late Interpreter _interpreter;
  late ImageProcessor imageProcessor;
  late TensorImage inputImage;
  late List<Object> inputs;

  Map<int, Object> outputs = {};
  TensorBuffer outputLocations = TensorBufferFloat([]);

  Classifier() {
    loadModel();
  }

  void performOperations(CameraImage cameraImage) {

    image_lib.Image convertedImage = convertCameraImage(cameraImage);
    if (Platform.isAndroid) {
      convertedImage = image_lib.copyRotate(convertedImage, 270);  // 있는게 Confidence 점수가 매우 높음.
      convertedImage = image_lib.flipHorizontal(convertedImage); // front camera mirror image issue
    }
    inputImage = TensorImage(TfLiteType.float32);
    inputImage.loadImage(convertedImage);
    inputImage = getProcessedImage();

    inputs = [inputImage.buffer];
  }

  // ConvertCameraImage: CameraImage -> Image의 아래 함수들은 공식적으로 사용되는 함수이므로 맞음.
  static image_lib.Image convertCameraImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    final image = image_lib.Image(width, height);

    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex =
            uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    int r = (y + v * 1436 / 1024 - 179).round();
    int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    int b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
    ((b << 16) & 0xff0000) |
    ((g << 8) & 0xff00) |
    (r & 0xff);
  }

  TensorImage getProcessedImage() {
    int padSize = max(inputImage.height, inputImage.width);
    imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        // .add(ResizeOp(192, 192, ResizeMethod.BILINEAR)) // 왜 192, 192?
        .add(ResizeOp(256, 256, ResizeMethod.BILINEAR)) // 수정
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  parseLandmarkData() {
    List<double> data = outputLocations.getDoubleList();
    // debugPrint("Parse Landmark data: " + data.toString());
    List rawResult = [];
    List tempResult = [];
    List scaledResult = [];
    var x, y, c;

    for (var i = 0; i < 51; i += 3) {
      // y = (data[0 + i] * 640).toInt();
      y = (data[0 + i] * 720).toInt();  // iOS: 640, Android: 720
      x = (data[1 + i] * 480).toInt();
      c = (data[2 + i]);

      if (i > 12) {
        rawResult.add([double.parse(data[1+i].toStringAsFixed(3)), double.parse(data[0+i].toStringAsFixed(3))]);
        tempResult.add([double.parse(data[0+i].toStringAsFixed(2)), double.parse(data[2+i].toStringAsFixed(2))]);
      }
      scaledResult.add([x, y, c]);
    }
    debugPrint("LOGG: Raw Result Lelbow : ${tempResult[2].toString()}");

    // return [rawResult, scaledResult];
    return [rawResult, scaledResult];
  }

  loadModel() async {
    try {
      // _interpreter = await Interpreter.fromAsset('models/movenet_from_project.tflite');
      // _interpreter = await Interpreter.fromAsset('models/movenet_thunder_f16.tflite');
      _interpreter = await Interpreter.fromAsset('models/movenet_thunder.tflite');

      debugPrint('Model Loaded: ' + _interpreter.toString());
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
    outputLocations = TensorBufferFloat([1, 1, 17, 3]);
  }

  runModel() async {
    Map<int, Object> outputs = {0: outputLocations.buffer};
    _interpreter.runForMultipleInputs(inputs, outputs);
  }
}












