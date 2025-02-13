import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:magicscreen/algorithms/types/detect_box.dart';
import 'package:onnxruntime/onnxruntime.dart';

// onnx + ultraface model
// https://github.com/onnx/models/tree/main/validated/vision/body_analysis/ultraface
class FaceDetectionOnnx {
  late OrtSessionOptions _sessionOptions;
  late OrtSession _session;
  late OrtRunOptions _runOptions;

  // = 'assets/models/version-RFB-320.onnx'
  FaceDetectionOnnx(String modelPath) {
    _runOptions = OrtRunOptions();
    _runOptions.setRunLogSeverityLevel(OrtLoggingLevel.warning.value);
    _runOptions.setRunLogVerbosityLevel(OrtLoggingLevel.warning.value);
    _loadModel(modelPath);
  }

  Future<void> _loadModel(String modelPath) async {
    OrtEnv.instance.init();
    OrtEnv.instance.availableProviders().forEach((element) {
      print('onnx provider=$element');
    });

    _sessionOptions = OrtSessionOptions()
      ..setInterOpNumThreads(1)
      ..setIntraOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final rawAssetFile = File(modelPath);
    final bytes = rawAssetFile.readAsBytesSync();
    _session = OrtSession.fromBuffer(bytes, _sessionOptions);
  }

  Future<img.Image> _loadImage(String path) async {
    final image2 = await img.decodeImageFile(path);
    return image2!;
  }

  // 'assets/images/face-1.png'
  Future<List<DetectBox>?> detectFile(String path) async {
    final image = await _loadImage(path);
    return detect(image);
  }

  List<DetectBox>? detect(img.Image image, {int topK = 1}) {
    final resizedImage = img.copyResize(image,
        width: 320, // model input size
        height: 240, // model input size
        maintainAspect: true,
        backgroundColor: img.ColorInt8.rgba(0, 0, 0, 0));

    final rgbBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);

    // shape = (3, height, width)
    List<List<List<double>>> normalizedData = List.generate(
        3,
        (_) => List.generate(
            resizedImage.height, (_) => List.filled(resizedImage.width, 0.0)));
    int index = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        normalizedData[0][y][x] = (rgbBytes[index] - 127.0) / 128.0;
        normalizedData[1][y][x] = (rgbBytes[index + 0] - 127.0) / 128.0;
        normalizedData[2][y][x] = (rgbBytes[index + 1] - 127.0) / 128.0;
        index += 3;
      }
    }

    final input = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(normalizedData
          .expand((innerList) => innerList.expand((subList) => subList))
          .toList()),
      [1, 3, resizedImage.height, resizedImage.width],
    );

    final outputs = _session.run(_runOptions, {_session.inputNames[0]: input});

    final scores = (outputs[0]!.value as List<List<List<double>>>).first;
    final boxes = (outputs[1]!.value as List<List<List<double>>>).first;

    var boxTopOne = [-1.0, -1.0, -1.0, -1.0, -1.0]; // score, x1,y1,x2,y2

    final List<DetectBox> detectBoxes = [];

    for (int i = 0; i < scores.length; i++) {
      if (scores[i][1] > 0.7) {
        boxTopOne = [
          scores[i][1],
          boxes[i][0],
          boxes[i][1],
          boxes[i][2],
          boxes[i][3]
        ];

        // 计算实际的x1,y1,x2,y2
        final resizeW = resizedImage.width;
        final resizeH = resizedImage.height;

        final w = image.width;
        final h = image.height;

        final scaleRatio = max(w / resizeW, h / resizeH);

        //  缩放后的尺寸
        var newWidth = (resizeW * scaleRatio).ceil();
        var newHeight = (resizeH * scaleRatio).ceil();

        // 填充的尺寸
        var deltaW = newWidth - w;
        var deltaH = newHeight - h;
        var top = (deltaH / 2).ceil();
        var left = (deltaW / 2).ceil();

        final box = DetectBox(
          boxTopOne[0],
          (boxTopOne[1] * newWidth - left).ceil(),
          (boxTopOne[2] * newHeight - top).ceil(),
          (boxTopOne[3] * newWidth - left).ceil(),
          (boxTopOne[4] * newHeight - top).ceil(),
          image.width,
          image.height,
        );
        detectBoxes.add(box);
      }
    }
    return detectBoxes.isEmpty ? null : detectBoxes.take(topK).toList();
  }

  void dispose() {
    _sessionOptions.release();
    _session.release();
    _runOptions.release();
  }
}
