import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:momentong/util/exercises_list.dart';

// Code to extract expert's pose recognition data.
// class Result extends StatelessWidget {
//   final String exercise;
//   List<List<dynamic>> recognitionFrames;
//
//   Result({
//     super.key,
//     required this.exercise,
//     required this.recognitionFrames
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint('LOGG: recognitionFramesNum: ${recognitionFrames.length}');
//     developer.log("LOGGG: recognitionFramesNum: ${recognitionFrames.toString()}");
//     // debugPrint('LOGG: recognitionFrames: ${recognitionFrames.toString()}');
//
//     return Scaffold(
//       backgroundColor: Colors.black54,
//       appBar: AppBar(
//         backgroundColor: Colors.black54,
//         centerTitle: true,
//         title: const Text('Result'),
//       ),
//       body: Center(
//         child: Text('Hello World')
//       )
//     );
//     }
// }

class Result extends StatefulWidget {
  final String exercise;
  List<List<dynamic>> recognitionFrames;

  Result({required this.exercise, required this.recognitionFrames});

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  int score = 0;

  Future<int> _fetchScoreData(List<List<dynamic>> userFrameData, List<List<dynamic>> proFrameData, int frameNum) async {
    debugPrint('LOGG: API REQUEST');
    final response = await http.post(
      Uri.parse("http://capstonedesign16.pythonanywhere.com/api"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'total_frames': frameNum,
        'tensor1': proFrameData,
        'tensor2': userFrameData,
      }),
    );
    debugPrint('LOGG: API RESPONSE');
    if (response.statusCode == 200) {
      debugPrint('LOGG: API RESPONSE SUCCESS');
      return double.tryParse(response.body)!.round();
    } else {
      debugPrint('LOGG: API RESPONSE FAIL ${response.statusCode}');
      debugPrint('LOGG: API RESPONSE FAIL ${response.body}');
      throw Exception('Request failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> userProcessedFrames = [];
    List<List<dynamic>> proProcessedFrames = [];
    int frameNum = 0;

    int userFramesNum = widget.recognitionFrames.length;
    int proFramesNum = proFrames[widget.exercise]!.length;

    if (proFramesNum > userFramesNum) {
      userProcessedFrames = widget.recognitionFrames;
      proProcessedFrames = proFrames[widget.exercise]!.sublist(proFramesNum-userFramesNum, proFramesNum);
      frameNum = userFramesNum;
    } else if (proFramesNum < userFramesNum) {
      userProcessedFrames = widget.recognitionFrames.sublist(userFramesNum-proFramesNum, userFramesNum);
      proProcessedFrames = proFrames[widget.exercise]!;
      frameNum = proFramesNum;
    } else {
      userProcessedFrames = widget.recognitionFrames;
      proProcessedFrames = proFrames[widget.exercise]!;
      frameNum = proFramesNum;
    }

    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        centerTitle: true,
        title: Text("Your ${widget.exercise} Score"),
      ),
      body: FutureBuilder<int>(
        future: _fetchScoreData(userProcessedFrames, proProcessedFrames, frameNum),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "전문가의 자세와 비교중이에요!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[100],
                          ),
                        ),
                      ),
                      CircularProgressIndicator()
                    ]
                )
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            score = snapshot.data!;
            String msg;
            if (score >= 80) {
              msg = "회원님 잘하고 계십니다!";
            } else if (score >= 60) {
              msg = "회원님 조금만 더 신경써봅시다..";
            } else {
              msg = "회원님 이러면 안되세요...";
            }

            return Center(
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[100],
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "당신의 점수는\n$score점!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.deepOrange,
                            ),
                          ),
                      ),
                    ]
                )
            )
            );
          }
        },
      ),
    );
  }
}