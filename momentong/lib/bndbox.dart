import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:momentong/util/pose_info.dart';


class BndBox extends StatefulWidget {
  final List<dynamic> jointFrames;
  // final int previewH;
  // final int previewW;
  // final double screenH;
  // final double screenW;

  const BndBox({
    required this.jointFrames,
    // required this.previewH,
    // required this.previewW,
    // required this.screenH,
    // required this.screenW,
  });

  @override
  BndBoxState createState() => BndBoxState();
}

class BndBoxState extends State<BndBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderKeypoints() {
      var lists = <Widget>[];

      for (var i = 0; i < widget.jointFrames.length; i++) {
        Widget tempWidget = Positioned(
            left: widget.jointFrames[i][0].toDouble()-100.0,
            top: widget.jointFrames[i][1].toDouble()-30.0,
            // width: 100.0,
            // height: 15.0,
            child: Container(
              child: Text(
                "● ${poseInfos[i]}",
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 12.0,
                ),
              ),
            ),
        );
        lists.add(tempWidget);
      }
      // widget.jointFrames.forEach((jointFrame) {
      //   var list = jointFrame["keypoints"].values.map<Widget>((k) {
      //     var _x = k["x"];
      //     var _y = k["y"];
      //     var scaleW, scaleH, x, y;
      //
      //
      //     // To solve mirror problem on front camera
      //     // if (x > 320) {
      //     //   var temp = x - 320;
      //     //   x = 320 - temp;
      //     // } else {
      //     //   var temp = 320 - x;
      //     //   x = 320 + temp;
      //     // }
      //
      //     return Positioned(
      //       left: x - 275,
      //       top: y - 50,
      //       width: 100,
      //       height: 15,
      //       child: Container(
      //         child: Text(
      //           "● ${k["part"]}",
      //           style: const TextStyle(
      //             color: Color.fromRGBO(37, 213, 253, 1.0),
      //             fontSize: 12.0,
      //           ),
      //         ),
      //       ),
      //     );
      //   }).toList();
      //
      //   // _getPrediction(_inputArr.cast<double>().toList());
      //   // _inputArr.clear();
      //   lists.addAll(list); // changed
      // });
      return lists;
    }

    return Stack(
      children: <Widget>[
        Stack(
          children: _renderKeypoints(),
        ),
      ],
    );
  }
}
