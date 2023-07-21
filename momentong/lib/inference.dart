import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:momentong/result.dart';
import 'package:momentong/pose.dart';
import 'package:momentong/estimator.dart';
import 'package:momentong/bndbox.dart';


class InferencePage extends StatefulWidget {
  final CameraDescription camera;
  final String exercise;

  const InferencePage({required this.camera, required this.exercise});

  @override
  _InferencePageState createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  List<List<dynamic>> _recognitionFrames = [];
  List<dynamic> _recognitions = [];
  late Estimator estimator;
  int _imageHeight = 0;
  int _imageWidth = 0;
  CameraController? _cameraController; // Added

  @override
  void initState() {
    super.initState();
    estimator = Estimator();
    estimator.loadModel().then((value) {
    });
    _initializeCamera(); // Added
  }

  // Added
  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  _setRecognitions(rawRecognitions, recognitions, imageHeight, imageWidth) {
    debugPrint('LOGG: InferencePage _setRecognitions called!');
    if (!mounted) {
      return;
    }
    setState(() {
      _recognitionFrames = _recognitionFrames..add(rawRecognitions);
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    // Added
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(widget.exercise),
      ),
      body: Stack(
        children: <Widget>[
          Pose(
            // camera: widget.camera, Changed
            cameraController: _cameraController!, // Added
            setRecognitions: _setRecognitions,
            model: estimator,
            isDetecting: false,
          ),
          // Padding(
          //   padding: EdgeInsets.all(5),
          //   child: _recognitions == null
          //       ? Container()
          //       : Container(
          //     height: MediaQuery.of(context).size.height * 0.7,
          //     width
          //   )
          // ),
          BndBox(
            jointFrames: _recognitions == null ? [] : _recognitions,
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              child: Text('Finish'),
              onPressed: () => _onExerciseFinish(
                context,
                widget.exercise,
                _recognitionFrames,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                )
              )
            )
          ),
        ],
      ),
    );
  }

  void _onExerciseFinish(
      BuildContext context,
      String exercise,
      List<List<dynamic>> recognitionFrames,
      ) async {
    // Added
    await _cameraController!.stopImageStream();
    _cameraController!.dispose();
    debugPrint("LOGG: Push result page");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Result(
          exercise: exercise,
          recognitionFrames: recognitionFrames,
        ),
      ),
    );
    // cameraController.dispose();
  }

  // For capturing ProFrames.
  @override
  void dispose() {
    debugPrint("LOGG: Pop result page");
    // String filePath = '~/StudioProjects/momentong/assets/imgs/pose_frames.txt';
    // String filePath = path.join(
    //   Directory.current.path, 'momentong', 'assets', 'imgs', 'pose_frames.txt'
    // );
    // File file = File(filePath);
    // RandomAccessFile outputFile = file.openSync(mode: FileMode.write);
    // outputFile.writeStringSync(_recognitionFrames.toString());
    // outputFile.closeSync();
    debugPrint("LOGG: recognitionFramesNum: ${_recognitionFrames.length}");
    debugPrint("LOGG: recognitionFrames: ${_recognitionFrames.toString()}");
    super.dispose();
  }
}