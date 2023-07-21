import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:momentong/inference.dart';


class Exercises extends StatelessWidget {
  final CameraDescription camera;
  final String title;
  final List<String> exercises;
  final Color color;

  const Exercises({
    required this.camera,
    required this.title,
    required this.exercises,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          centerTitle: true,
          title: Text(title),
        ),
        body: Center(
            child: Container(
                height: 500,
                child: Swiper(
                    itemCount: exercises.length,
                    loop: false,
                    viewportFraction: 0.8,
                    scale: 0.9,
                    outer: true,
                    pagination: SwiperPagination(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.all(32.0),
                    ),
                    onTap: (index) => _onSelect(context, exercises[index]),
                    itemBuilder: (BuildContext, int index) {
                      return Center(
                        child: Container(
                          height: 360,
                          child: ExerciseCard(
                            exercise: exercises[index],
                            color: color,
                          ),
                        ),
                      );
                    }
                )
            )
        )
    );
  }

  void _onSelect(BuildContext context, String selectExercise) async {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InferencePage(
              camera: camera,
              exercise: selectExercise,
            )
        )
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String exercise;
  final Color color;

  const ExerciseCard({required this.exercise, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/imgs/" + "benchpress" + ".png",
              fit: BoxFit.contain,
            ),
          ),
          Text(
            exercise,
            style: TextStyle(fontSize: 24),
          )
        ],
      ),
    );
  }
}