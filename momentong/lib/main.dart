import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:momentong/exercises.dart';
import 'package:momentong/util/exercises_list.dart';
import 'package:momentong/util/routing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras;

  cameras = await availableCameras();
  final ourCamera = cameras[1];

  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyApp(camera: ourCamera)
      ));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({
    super.key,
    required this.camera,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text('Momento'),
        centerTitle: true,
      ),
      body: Center(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                            'Muscle,\nNothing but Everything',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.orange,
                            )
                        )
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        child: const Text('Upper Body'),
                        onPressed: () => _onExerciseSelect(
                          context,
                          'Upper Body',
                          upperExercises,
                          Colors.deepOrange,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          minimumSize: Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        child: const Text('Lower Body'),
                        onPressed: () => _onExerciseSelect(
                          context,
                          'Lower Body',
                          lowerExercises,
                          Colors.teal,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          minimumSize: Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        child: const Text('Whole Body'),
                        onPressed: () => _onExerciseSelect(
                          context,
                          'Whole Body',
                          wholeExercises,
                          Colors.indigo,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          minimumSize: Size(160, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }

  void _onExerciseSelect(
      BuildContext context,
      String title,
      List<String> exercises,
      Color color
      ) async {
    debugPrint('exercise pushed');
    Navigator.push(
        context,
        ScaleRoute(
            page: Exercises(
                camera: camera,
                title: title,
                exercises: exercises,
                color: color
            )
        )
    );
  }
}
