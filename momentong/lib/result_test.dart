import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

List<List<List<double>>> generateRandomTensor(int rows, int cols, int depth) {
  final random = Random();
  final tensor = List.generate(
      rows,
          (_) => List.generate(
          cols, (_) => List.generate(depth, (_) => random.nextDouble())));

  return tensor;
}

Future<void> queryData(int totalFrames, List<List<List<double>>> tensor1, List<List<List<double>>> tensor2) async {
  final url = Uri.parse('http://capstonedesign16.pythonanywhere.com/api');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'total_frames': totalFrames,
      'tensor1': tensor1,
      'tensor2': tensor2,
    }),
  );

  if (response.statusCode == 200) {
    print('Data queried successfully');
    final score = double.tryParse(response.body);
    print('Score: $score');
  } else {
    print('Failed to query data: ${response.statusCode}');
    print('Failed to query data: ${response.body}');
  }
}


void main() {
  final totalFrames = 5;

  final tensor1 = generateRandomTensor(totalFrames, 12, 2);
  final tensor2 = generateRandomTensor(totalFrames, 12, 2);
  print(tensor1);
  queryData(totalFrames, tensor1, tensor2);
}