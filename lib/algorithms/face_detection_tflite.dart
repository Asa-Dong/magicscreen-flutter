import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// tflite + mediapipe face detection model
// https://github.com/patlevin/face-detection-tflite/blob/main/fdlite/face_detection.py
// 还没有实现
class FaceDetectionTflite {
  late Interpreter _interpreter;

   FaceDetectionTflite() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset(
        'assets/models/face_detection_short_range.tflite');
    print(_interpreter.getInputTensors());
    print(_interpreter.getOutputTensors());
  }

  Future<img.Image> _loadImage(String path) async {
    final file = File(path);
    return img.decodeImage(file.readAsBytesSync())!;
  }

  Future<void> _detectFace() async {
    final image = await _loadImage('assets/images/face-2.png');

    // 参数是 128x128 去掉alpha通道
    final resizedImage = img.copyResize(image, width: 128, height: 128);
    final rgbBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
    // .map((e) =>  (e-127.5)/127.5)
    // .toList();

    // shape = (width, height, 3)
    List<List<List<double>>> normalizedData = List.generate(resizedImage.height,
            (_) => List.generate(resizedImage.width, (_) => List.filled(3, 0.0)));

    int index = 0;
    for (int x = 0; x < resizedImage.width; x++) {
      for (int y = 0; y < resizedImage.height; y++) {
        // normalizedData[x][y][0] = (rgbBytes[index] - 127.0) / 128.0;
        // normalizedData[x][y][1] = (rgbBytes[index + 0] - 127.0) / 128.0;
        // normalizedData[x][y][2] = (rgbBytes[index + 1] - 127.0) / 128.0;

        // normalizedData[x][y][0] = rgbBytes[index] / 1.0;
        // normalizedData[x][y][1] = rgbBytes[index + 1] / 1.0;
        // normalizedData[x][y][2] = rgbBytes[index + 2] / 1.0;

        normalizedData[x][y][0] = rgbBytes[index] * 2.0 / 255.0 + -1.0;
        normalizedData[x][y][1] = rgbBytes[index + 1] * 2.0 / 255.0 + -1.0;
        normalizedData[x][y][2] = rgbBytes[index + 2] * 2.0 / 255.0 + -1.0;

        // normalizedData[x][y][0] = rgbBytes[index] / 255.0;
        // normalizedData[x][y][1] = rgbBytes[index + 1] / 255.0;
        // normalizedData[x][y][2] = rgbBytes[index + 2] / 255.0;


        index += 3;
      }
    }

    // shape = (1, 128, 128, 3)
    final input = [normalizedData];

    // // 将图片数据转换为模型输入格式 [1, 128, 128, 3]
    // final inputBuffer = Float32List(1 * 128 * 128 * 3);
    // for (int i = 0; i < rgbBytes.length; i += 3) {
    //   inputBuffer[i] = (rgbBytes[i] - 127.5) / 127.5; // R 通道，归一化到 [0, 1]
    //   inputBuffer[i + 1] = (rgbBytes[i + 1] - 127.5) / 127.5; // G 通道
    //   inputBuffer[i + 2] = (rgbBytes[i + 2] - 127.5) / 127.5; // B 通道
    // // }
    // final input = normalizedData.reshape([1, 128, 128, 3]);

    final output1 = List.filled(1 * 896 * 16, 0.0).reshape([1, 896, 16]);
    final output2 = List.filled(1 * 896 * 1, 0.0).reshape([1, 896, 1]);
    // map
    final outputs = {
      0: output1,
      1: output2,
    };

    _interpreter.runForMultipleInputs([input], outputs);

    // 解析输出
  }
}

