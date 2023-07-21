import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
// import 'package:image/image.dart' as image_lib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momentong/estimator.dart';


typedef void Callback(List<dynamic> rawData, List<dynamic> scaledData, int h, int w);

class Pose extends StatefulWidget {
  // final CameraDescription camera; // Changed
  final CameraController cameraController; // Added
  final Callback setRecognitions;
  final Estimator model;
  bool isDetecting;

  // Pose({required this.camera, required this.setRecognitions, required this.model, required this.isDetecting}); // Changed
  Pose({required this.cameraController, required this.setRecognitions, required this.model, required this.isDetecting}); // Added

  @override
  _PoseState createState() => _PoseState();
}

class _PoseState extends State<Pose> {
  // late CameraController controller; // Changed
  // bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    // Added
    if (!widget.cameraController.value.isInitialized) {
      widget.cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        _startImageStream();
      });
    } else {
      _startImageStream();
    }

    // Changed
    // controller = CameraController(
    //   widget.camera,
    //   ResolutionPreset.medium,
    // );

    // controller.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   // initState()에서 initialize하기 이전에 build가 먼저 실행될 수 있음. (async이기 때문) 따라서 initialize 이후 다시 build하도록 setState()
    //   setState(() {});
    //
    //   // Pose 위젯이 위젯 트리에 들어갈때 한번만 실행됨. 얘는 끝나지 않는 함수니까 계속 아래 imagestream이 진행되고 있는거임.
    //   // 얘는 계속 실행되는 거 확인함.
    //   controller.startImageStream((CameraImage image) {
    //     debugPrint("LOGG: Pose startImageStream isDetecting: ${widget.isDetecting}");
    //     if (!widget.isDetecting) {
    //       widget.isDetecting = true;
    //       debugPrint("LOGG: Pose startImageStream isDetecting: ${widget.isDetecting}");
    //
    //       widget.model.performOperations(image);
    //       widget.model.runModel();
    //       List<dynamic> rawResults = widget.model.parseLandmarkData()[0];
    //       List<dynamic> scaledResults = widget.model.parseLandmarkData()[1];
    //       debugPrint("LOGG: Estimation results out!");
    //       debugPrint('Recognitions: ' + scaledResults.toString());
    //
    //       widget.setRecognitions(rawResults, scaledResults, image.height, image.width); // 이게 async로 작용하고, 카메라 리소스를 다 뺏어먹어서 그런듯..?
    //       // debugPrint("LOGG: Sleep start");
    //       // isDetecting = false;정
    //     }
    //   });
    // });
  }

  // Added
  void _startImageStream() {
    widget.cameraController.startImageStream((CameraImage image) {
      if (!widget.isDetecting) {
        widget.isDetecting = true;

        widget.model.performOperations(image);
        widget.model.runModel();
        List<dynamic> rawResults = widget.model.parseLandmarkData()[0];
        List<dynamic> scaledResults = widget.model.parseLandmarkData()[1];
        // debugPrint('Recognitions: ' + scaledResults.toString());

        widget.setRecognitions(rawResults, scaledResults, image.height, image.width);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    //Added
    if (!widget.cameraController.value.isInitialized) {
      return Container();
    }

    // Changed
    // if (controller == null || !controller.value.isInitialized) {
    //   return Container();
    // }

    Size cSize = MediaQuery.of(context).size;
    var screenH = max(cSize.height, cSize.width);
    var screenW = min(cSize.height, cSize.width);

    // Size? pSize = controller.value.previewSize; // Changed
    Size? pSize = widget.cameraController.value.previewSize; // Added
    var previewH = max(pSize!.height, pSize.width);
    var previewW = min(pSize!.height, pSize.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
      screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
      screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      // child: CameraPreview(controller), // Changed
      child: CameraPreview(widget.cameraController), // Added
    );
  }

  @override
  void dispose() {
    // controller?.dispose(); // Changed
    widget.cameraController.dispose(); // Added
    super.dispose();
  }
}



